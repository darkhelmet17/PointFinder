package
{
	/**
	 * Import needed packages
	 */
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.text.TextField;
	
	public class PointFinder extends Sprite
	{
		/**
		 * Global variables
		 */
		
		// variables for image file(s)
		private var PICTURE_FILE:File;
		
		// variables for Loader and URLRequest
		private var myLoader:Loader;
		private var fileRequest:URLRequest;
		
		// variables for bitmaps
		private var bmd:BitmapData;
		private var image:Bitmap;
		
		// text field for starting message
		private var label:TextField;
		
		// flag for seeing if the field is still on screen
		private var textFlag:Boolean;
		
		// text to be displayed on opening screen
		private var LABEL_TEXT:String = "To begin analyzing images, press any key and select an image file:";
		
		private const BRIGHTNESS_THRESHOLD:uint = 3550000;
		
		/**
		 * Constructor
		 */
		public function PointFinder()
		{
			// create text field and place it on screen
			label = new TextField();
			label.text = LABEL_TEXT;
			label.width = stage.stageWidth;
			label.y = stage.stageHeight/2-20;
			label.x = stage.stageWidth/5;
			addChild(label);
			
			// set flag to indicate text field is currently on the stage
			textFlag = true;
			
			// add event listener for the mouse click
			stage.addEventListener(MouseEvent.MOUSE_UP, _onClick);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyPressed);
		}
		
		/**
		 * keyPressed() is a function that is called when a key is pressed on the keyboard
		 * 
		 * This function prompts the user with a file browser to select a new image file
		 */
		private function keyPressed(event:Event) :void {
			
			// check if text field is currently being displayed; if so, remove it and set flag to false
			if (textFlag) {
				removeChild(label);
				textFlag = false;
			}
			
			// prompt user for the file to be loaded
			PICTURE_FILE = new File();
			PICTURE_FILE.addEventListener(Event.SELECT, onSelect);
			PICTURE_FILE.browse();
		}
		
		/**
		 * onSelect() is a function that is called when a user selects an image to load
		 * 
		 * This function takes the image file and loads it into the program
		 */
		private function onSelect(event:Event) :void {
			myLoader = new Loader();
			fileRequest = new URLRequest(PICTURE_FILE.url);
			myLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoaded);
			myLoader.load(fileRequest);
		}
		
		/**
		 * onImageLoaded() is a function that is called once an image file has been successfully loaded into the program
		 * 
		 * This function takes the bitmap data of the loaded image and adds it to the screen
		 */
		private function onImageLoaded(e:Event) :void 
		{
			// create the bitmap and set the width/height
			image = new Bitmap(e.target.content.bitmapData);
			image.width = stage.stageWidth;
			image.height = stage.stageHeight;
			
			addChild(image);
		}
		
		/**
		 * _onClick is a function that is called when the mouse is clicked
		 * 
		 * This function calculates the center of the reflector that is clicked on and finds the approximate radius of the reflector, and
		 * draws a circle around that area for the user to see
		 */
		
		public function _onClick(event:MouseEvent) :void {
			
			// variables for drawing the circle around reflectors
			var radius:uint = 0;
			var x:Number = 0;
			var y:Number = 0;
			
			// variables used to calculate average positions of pixels
			var sumXCoords:uint = 0;
			var sumYCoords:uint = 0;
			var totalPixels:uint = 0;
			
			// variables for calculating the average height
			var cols:uint = 0;
			var heights:uint = 0;
			var currentHeight:uint = 0;
			var avgHeight:uint = 0;
			
			// variable for calculating the average width
			var rows:uint = 0;
			var widths:uint = 0;
			var currentWidth:uint = 0;
			var avgWidth:uint = 0;
			
			// boolean flag used for height/width calculations
			var flag:Boolean = false;
			
			// remove current image being displayed and retrieve it's bitmapData
			removeChild(image);
			bmd = image.bitmapData;
			
			// Get location of mouse click
			var target:* = event.target;
			var location:Point = new Point(target.mouseX*7.3, target.mouseY*7.3);
			location = target.localToGlobal(location);
			
			var circle:Sprite = new Sprite();
			
			// Check pixels in 100x100 pixel box around the mouse position at the time it was clicked
			for (var i:uint = location.x - 50; i < location.x + 50; i++) {
				for (var j:uint = location.y - 50; j < location.y + 50; j++){
					
					// If "brightness" is greater than a certain amount, color that pixel red
					if (calcBrightness(bmd.getPixel(i, j)) > BRIGHTNESS_THRESHOLD) {
						bmd.setPixel(i,j,0xff0000); // set the pixel to red
						totalPixels++; //increment the total number of pixels by 1
						sumXCoords += i; // add the i coordinate to running total
						sumYCoords += j; // add the j coordinate to running total
					}
				}
			}
			
			// calculate the center of the circle
			x = sumXCoords/totalPixels;
			y = sumYCoords/totalPixels;

			
			/* find the average width of the hilighted area  */
			
			// loop through each row first
			for (i = location.x - 50; i < location.x + 50; i++) {
				
				// reset internally used variables
				currentWidth = 0;
				flag = false;
				
				// loop through each column in the row
				for (j = location.y - 50; j < location.y + 50; j++) {
					
					// check for marked pixel
					if (bmd.getPixel(i, j) == 0xff0000) {
						currentWidth++; // increment the width of this row by 1
						flag = true; // set a flag so we know this row has at least one marked pixel in it
					}
				}
				
				// add this row's width to a running total
				widths += currentWidth;
				
				// check the flag; if it's set, increment the total number of rows by 1
				if (flag == true)
					rows++;
			}
			
			// calculate the average width of the reflector
			avgWidth = widths/rows;

			
			
			
			
			/* find the average height of the hilighted area */
			
			// loop through each column first
			for (j = location.y - 50; j < location.y + 50; j++) {
				
				// reset internally used variables
				currentHeight = 0;
				flag = false;
				
				// loop through each row in the column
				for(i = location.x - 50; i < location.x + 50; i++) {
					
					// check for marked pixel
					if (bmd.getPixel(i, j) == 0xff0000) {
						currentHeight++; // increment the height of this column by 1
						flag = true; // set flag to true so that we know there is at least one marked pixel in this column
					}
				}
				
				// add this columns height to a running total
				heights += currentHeight;
				
				// check the flag; if it's true, increment the total number of columns by 1
				if (flag == true)
						cols++;
			}
			
			// calculate the average height of the reflector
			avgHeight = heights/cols;
			
			// average the width and height together to get the radius
			radius = (avgWidth + avgHeight)/2;
			
			// draw the circle around the reflector
			circle.graphics.clear();
			circle.graphics.beginFill(0xFF0000, 0.0);
			circle.graphics.lineStyle(2.0);
			circle.graphics.drawCircle(x, y, radius-10); // -10 normalizes the radius of the circle
			circle.graphics.endFill();
			bmd.draw(circle);
	
			// display updated image
			image.bitmapData = bmd;
			addChild(image);
		}
		
		
		/**
		 * calcBrightness() is a function to calculate the brightness of a pixel
		 */
		private function calcBrightness(pixel:uint) :Number {
			
			var r:uint = 0xff0000 & pixel; // get only the red value of the pixel
			var g:uint = 0x00ff00 & pixel; // get only the green value of the pixel
			var b:uint = 0x0000ff & pixel; // get only the blue value of the pixel
			
			return (0.2126 * r) + (0.7152 * g) + (0.0722 * b)
		}
	}
}