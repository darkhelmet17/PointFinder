package
{
	// testing commit
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
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
		// Global variables
		var PICTURE_1_URL:String = "IMG_1882.jpg";
		var PICTURE_2_URL:String = "IMG_1883.jpg";
		
		var PICTURE_1_FILE:File;
		var PICTURE_2_FILE:File;
		
		var myLoader:Loader;
		var fileRequest:URLRequest;
		
		var bmd:BitmapData;
		var prev_bmd:BitmapData;
		var image:Bitmap;
		
		var canvas:MovieClip;
		
		public function Main()
		{
			
			PICTURE_1_FILE = new File(File.applicationDirectory.nativePath).resolvePath(PICTURE_1_URL);
			PICTURE_2_FILE = new File(File.applicationDirectory.nativePath).resolvePath(PICTURE_2_URL);
			
			// Load image to be displayed
			myLoader = new Loader();
			fileRequest = new URLRequest(PICTURE_2_FILE.url);
			myLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoaded);
			myLoader.load(fileRequest);
			
			// add event listener for the mouse click
			stage.addEventListener(MouseEvent.MOUSE_UP, _onClick);
			
			function onImageLoaded(e:Event):void 
			{
				image = new Bitmap(e.target.content.bitmapData);
				image.width = stage.stageWidth;
				image.height = stage.stageHeight;
				
				canvas = new MovieClip();
				addChild(canvas);
				
				canvas.bmap = image.bitmapData;
				canvas.addChild(image);
			}
		}
		
		public function _onClick(event:MouseEvent):void {
			// remove current image being displayed and retrieve it's bitmapData
			canvas.removeChild(image);
			bmd = image.bitmapData;
			
			// Get location of mouse click
			var target:* = event.target;
			var location:Point = new Point(target.mouseX*7.3, target.mouseY*7.3);
			location = target.localToGlobal(location);
			
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
					if (brightness > 3500000)
						bmd.setPixel(i,j,0xff0000);
				}
			}
			
			// display updated image
			image.bitmapData = bmd;
			canvas.addChild(image);
		}
	}
}