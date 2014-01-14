package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.net.URLRequest;
	
	public class Main extends Sprite
	{
		/* Global variables */
		
		// variables for image(s)
		const PICTURE_1_URL:String = "IMG_1882.jpg";
		const PICTURE_2_URL:String = "IMG_1883.jpg";
		
		// variables for image file(s)
		var PICTURE_1_FILE:File;
		var PICTURE_2_FILE:File;
		
		// variables for Loader and URLRequest
		var myLoader:Loader;
		var fileRequest:URLRequest;
		
		// variables for bitmaps
		var bmd:BitmapData;
		var image:Bitmap;
		
		// variable for canvas
		var canvas:MovieClip;
		
		public function Main()
		{
			// Load image into file
			PICTURE_1_FILE = new File(File.applicationDirectory.nativePath).resolvePath(PICTURE_1_URL);
			PICTURE_2_FILE = new File(File.applicationDirectory.nativePath).resolvePath(PICTURE_2_URL);
			
			// Load image to be displayed
			myLoader = new Loader();
			fileRequest = new URLRequest(PICTURE_2_FILE.url);
			myLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoaded);
			myLoader.load(fileRequest);
			
			// add event listener for the mouse click
			stage.addEventListener(MouseEvent.MOUSE_UP, _onClick);
			
			// display image once it's loaded into the program
			function onImageLoaded(e:Event):void 
			{
				// create the bitmap and set the width/height
				image = new Bitmap(e.target.content.bitmapData);
				image.width = stage.stageWidth;
				image.height = stage.stageHeight;
				
				// create the canvas and add it to the stage
				canvas = new MovieClip();
				addChild(canvas);
				
				// Load bitmap into the canvas, and add image to the canvas
				canvas.bmap = image.bitmapData;
				canvas.addChild(image);
			}
		}
		
		public function _onClick(event:MouseEvent):void {
			
			// internal function variables
			var countX:uint = 0;
			var xCoord:uint = 0;
			var width:uint = 0;
			
			var countY:uint = 0;
			var length:uint = 0;
			var yCoord:uint = 0;
			
			var radius:uint = 0;
			
			// remove current image being displayed and retrieve it's bitmapData
			canvas.removeChild(image);
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
					var r:uint = 0xff0000 & bmd.getPixel(i,j);
					var g:uint = 0x00ff00 & bmd.getPixel(i,j);
					var b:uint = 0x0000ff & bmd.getPixel(i,j);
					var brightness:Number = (0.2126 * r) + (0.7152 * g) + (0.0722 * b);
					
					// If "brightness" is greater than a certain amount, color that pixel red
					if (brightness > 3500000) {
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
			
			
			// Use the longer of width and length to set the radius of the circle
			if (width > length)
				radius = width;
			else
				radius = length;
			
			// draw the circle around the reflector
			circle.graphics.clear();
			circle.graphics.beginFill(0xFF0000, 0.0);
			circle.graphics.lineStyle(2.0);
			circle.graphics.drawCircle(xCoord, yCoord, radius-10); // -10 normalizes the size of the circle
			circle.graphics.endFill();
			bmd.draw(circle);
			
			// display updated image
			image.bitmapData = bmd;
			canvas.addChild(image);
		}
	}
}