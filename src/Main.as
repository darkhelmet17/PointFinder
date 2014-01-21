package
{
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
	
	public class Main extends Sprite
	{
		/* Global variables */
		
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
		private var flag:Boolean;
		
		private var LABEL_TEXT:String = "To begin analyzing images, press any key and select an image file:";
		
		public function Main()
		{
			// create text field and place it on screen
			label = new TextField();
			label.text = LABEL_TEXT;
			label.width = stage.stageWidth;
			label.y = stage.stageHeight/2-20;
			label.x = stage.stageWidth/5;
			addChild(label);
			
			// set flag to indicate text field is currently on the stage
			flag = true;
			
			// add event listener for the mouse click
			stage.addEventListener(MouseEvent.MOUSE_UP, _onClick);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyPressed);
		}
		
		// Load new image when key is pressed
		private function keyPressed(event:Event) :void {
			
			// check if text field is currently being displayed; if so, remove it and set flag to false
			if (flag) {
				removeChild(label);
				flag = false;
			}
			
			// prompt user for the file to be loaded
			PICTURE_FILE = new File();
			PICTURE_FILE.addEventListener(Event.SELECT, onSelect);
			PICTURE_FILE.browse();
		}
		
		// Load image to be displayed
		private function onSelect(event:Event) :void {
			myLoader = new Loader();
			fileRequest = new URLRequest(PICTURE_FILE.url);
			myLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoaded);
			myLoader.load(fileRequest);
		}
		
		// display image once it's loaded into the program
		private function onImageLoaded(e:Event) :void 
		{
			// create the bitmap and set the width/height
			image = new Bitmap(e.target.content.bitmapData);
			image.width = stage.stageWidth;
			image.height = stage.stageHeight;
			
			addChild(image);
		}
		
		public function _onClick(event:MouseEvent) :void {
			
			// internal function variables
			var countX:uint = 0;
			var xCoord:uint = 0;
			var width:uint = 0;
			
			var countY:uint = 0;
			var length:uint = 0;
			var yCoord:uint = 0;
			
			var radius:uint = 0;
			
			// remove current image being displayed and retrieve it's bitmapData
			removeChild(image);
			bmd = image.bitmapData;
			
			// Get location of mouse click
			var target:* = event.target;
			var location:Point = new Point(target.mouseX*7.3, target.mouseY*7.3);
			location = target.localToGlobal(location);
			
			var circle:Sprite = new Sprite();
			
			// Check pixels in 100x100 box around the mouse position
			for (var i:uint = location.x-50; i < location.x+50; i++) 
			{
				for (var j:uint = location.y-50; j < location.y+50; j++)
				{
					// Get RGB values from pixel and calculate the "brightness" of that pixel"
					var r:uint = 0xff0000 & bmd.getPixel(i,j); // get only the red value of the pixel
					var g:uint = 0x00ff00 & bmd.getPixel(i,j); // get only the green value of the pixel
					var b:uint = 0x0000ff & bmd.getPixel(i,j); // get only the blue value of the pixel
					var brightness:Number = (0.2126 * r) + (0.7152 * g) + (0.0722 * b);
					
					// If "brightness" is greater than a certain amount, color that pixel red
					if (brightness > 3550000) {
						bmd.setPixel(i,j,0xff0000);
					}
				}
			}
			
			// finds longest in height
			for (i = location.x - 50; i < location.x + 50; i++) {
				countX = 0;
				for (j = location.y-50; j < location.y+50; j++) {
					if (bmd.getPixel(i, j) == 0xff0000) {
						countX++;
					}
				}
				if (countX > length) {
					length = countX;
					xCoord = i;
				}
			} 
			
			// find the longest in width
			for (j = location.y - 50; j < location.y + 50; j++) {
				countY = 0;
				for (i = location.x - 50; i < location.x + 50; i++) {
					if (bmd.getPixel(i, j) == 0xff0000) {
						countY++;
					}
				}
				if (countY > width) {
					width = countY;
					yCoord = j;
				}
			}
			
			
			var widths:uint = 0;
			var rows:uint = 0;
			var flag:uint = 0;
			
			// find the widths
			for (i = location.x - 50; i < location.x + 50; i++) {
				for (j = location.y - 50; j < location.y + 50; j++) {
					if (bmd.getPixel(i, j) == 0xff0000) {
						if (flag == 0) {
							flag = 1;
							rows++;
						}
						widths++;
					}
				}
				flag = 0;
			}
			
			var avgWidth:uint = 1;
			if (rows > 0)
				avgWidth = widths / rows;
			
			
			var heights:uint = 0;
			var cols:uint = 0;
			
			// find the heights
			for (i = location.y - 50; i < location.y + 50; i++) {
				for (j = location.x - 50; j < location.x + 50; j++) {
					if (bmd.getPixel(i, j) == 0xff0000) {
						if (flag == 0) {
							flag = 1;
							cols++;
						}
						heights++;
					}
				}
				flag = 0;
			}
			
			var avgHeight:uint = 1;
			if (cols > 1)
				avgHeight = heights / cols;
			
			// Use the longer of width and length to set the radius of the circle
			if (avgWidth > avgHeight)
				radius = avgHeight;
			else
				radius = avgWidth;
			
			// draw the circle around the reflector
			circle.graphics.clear();
			circle.graphics.beginFill(0xFF0000, 0.0);
			circle.graphics.lineStyle(2.0);
			circle.graphics.drawCircle(xCoord, yCoord, radius+25); // +25 normalizes the size of the circle
			circle.graphics.endFill();
			bmd.draw(circle);
	
			// display updated image
			image.bitmapData = bmd;
			addChild(image);
		}
	}
}