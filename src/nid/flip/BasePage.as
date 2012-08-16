package nid.flip 
{
	import flash.display.AVM1Movie;
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import nid.FlipBook;
	import nid.flip.events.PageEvent;
	import nid.Preloader;
	
	/**
	 * ...
	 * @author Nidin P Vinayakan
	 */
	public class BasePage extends MovieClip 
	{
		private var bg:Shape;
		private var shadow:Shape;
		private var color:uint = 0x000000;
		private var preloader:Preloader;
		private var bookmark:BookMark;
		private var rounded_corner:XML;
		
		public var content:DisplayObject;
		public var type:String;
		public var side:String;
		public var index:int;
		
		public function BasePage(index:int, width:int, height:int, type:String, side:String, url:String = "", _bookmark:String = "",rounded_corner:XML=null)
		{
			this.rounded_corner = rounded_corner;
			this.index = index;
			this.type = type;
			this.side = side;
			
			bg 		= new Shape();
			
			if (_bookmark != "")
			{
				bookmark 	= new BookMark(_bookmark);
				bookmark.x 	= side == "left"?width: 0;
				bookmark.rotation = side == "left"?0: -180;
				bookmark.y 	= FlipBook.bookmark_y + (side == "left"?0:bookmark.height) + 5;
				bookmark.addEventListener(MouseEvent.CLICK, onBookMarkClick);
				if (side == "right") 
				{
					FlipBook.bookmark_y = bookmark.y;
				}
			}
			
			if (type == "font_cover")
			{
				if (side == "left")
				{
					width += FlipBook.width_diff;
					height += (FlipBook.width_diff * 2);
					bg.y = -FlipBook.height_diff;
				}
				else
				{
					width += FlipBook.width_diff;
					height += (FlipBook.width_diff * 2);
					bg.x = -FlipBook.width_diff;
					bg.y = -FlipBook.height_diff;
				}
			}
			else if(type=="back_cover")
			{
				if (side == "left")
				{
					width += FlipBook.width_diff;
					height += (FlipBook.width_diff * 2);
					bg.y = -FlipBook.height_diff;
				}
				else
				{
					width += (FlipBook.width_diff * 2);
					height += (FlipBook.height_diff * 2);
					bg.x = -FlipBook.width_diff;
					bg.y = -FlipBook.height_diff;
				}
			}
			else
			{
				color = 0xFFF9DC;
				//color = 0x000000;
			}
			
			//bg.graphics.lineStyle(1, 0x00ff00);
			bg.graphics.beginFill(color);
			
			if(rounded_corner !=null && rounded_corner.text() == "true")
				bg.graphics.drawRoundRect(0, 0, width, height, rounded_corner.@ellipseWidth, rounded_corner.@ellipseHeight);
			else 
				bg.graphics.drawRect(0, 0, width, height);
			
			bg.graphics.beginFill(0x6A675B);
			bg.graphics.drawRect(0, 0, 1, height);
			bg.graphics.endFill();
			addChild(bg);
			
			if (FlipBook.inner_shadow)
			{
				shadow 	= new Shape();
				var colors:Array = [0x000000, 0x000000];
				var alphas:Array = [0.15, 0];
				var ratios:Array = [0, 125];
				var matr:Matrix = new Matrix();
				matr.createGradientBox(50, height, 0, 0, 0);
				
				//matr.rotate(90 * FlipBook.DEGREE_CONST);
				
				shadow.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matr, SpreadMethod.PAD);        
				shadow.graphics.drawRect(0, 0, 50, height);
				addChild(shadow);
				
				if (side == "right")
				{
					shadow.rotation = 180;
					shadow.x = width
					shadow.y = height;
				}
			}
			if (bookmark != null) addChild(bookmark);
			
			preloader = new Preloader();
			preloader.x = (width - preloader.width) / 2;
			preloader.y = (height - preloader.height) / 2;
			
			if (url != "")
			{
				load(url);
			}
		}
		
		private function onBookMarkClick(e:MouseEvent):void 
		{
			dispatchEvent(new PageEvent(PageEvent.BOOK_MARK, { index:index, side:side } ));
		}
		
		public function load(url:String):void 
		{
			if (url == null || url == "") return;
			
			preloader.progress(1);
			addChild(preloader);
			
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
			loader.load(new URLRequest(url));
		}
		
		private function onProgress(e:ProgressEvent):void 
		{
			preloader.progress(Math.round(e.bytesLoaded / e.bytesTotal * 100));
			dispatchEvent(e);
		}
		
		private function onIOError(e:IOErrorEvent):void 
		{
			trace('onIOError');
			if (this.contains(preloader)) removeChild(preloader);
		}
		
		private function onComplete(e:Event):void 
		{
			try {
				content = e.currentTarget.content as DisplayObject;
				if (type == "font_cover")
				{
					if (side == "left")
					{
						content.y = -FlipBook.height_diff;
					}
					else
					{
						content.x = -FlipBook.width_diff;
						content.y = -FlipBook.height_diff;
					}
				}
				else if(type=="back_cover")
				{
					if (side == "left")
					{
						content.y = -FlipBook.height_diff;
					}
					else
					{
						content.x = -FlipBook.width_diff;
						content.y = -FlipBook.height_diff;
					}
				}
				if (this.contains(preloader)) removeChild(preloader);
				addChild(content);
				if (FlipBook.inner_shadow)
				{
					shadow.graphics.clear();
					shadow.graphics.drawRect(0, 0, 50, content.height);
					addChild(shadow);
				}
				if (bookmark != null) addChild(bookmark);
				bg.graphics.clear();
			}catch (e:Error) { };
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
	}

}