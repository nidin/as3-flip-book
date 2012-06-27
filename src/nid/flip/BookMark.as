package nid.flip 
{
	import flash.display.*;
	import flash.geom.*;
	import flash.text.*;
	import nid.utils.*;
	
	/**
	 * ...
	 * @author Nidin P Vinayakan
	 */
	public class BookMark extends Sprite 
	{
		[Embed(source="../../../assets/bookmark_bg.png")]
		private var bg_img:Class;
		private var txt:TextField;
		private var bg:Shape;
		private var bg_image:Bitmap;
		private var holder:Sprite;
		
		public var index:int;
		
		public function BookMark(title:String) 
		{
			this.buttonMode = true;
			this.mouseChildren = false;
			
			holder = new Sprite();
			addChild(holder);
			
			var bg_data:BitmapData = Bitmap(new bg_img()).bitmapData;
			var op_data:BitmapData = new BitmapData(bg_data.width, 1);
			op_data.copyPixels(bg_data, new Rectangle(0, 6, bg_data.width, 1), new Point());
			bg = new Shape();
			
			var format:TextFormat =  new TahomaText().txt.defaultTextFormat;
			format.color = 0xffffff;
			
			txt = new TextField();
			txt.selectable = false;
			txt.cacheAsBitmap = true;
			txt.autoSize = TextFieldAutoSize.LEFT;
			txt.embedFonts = true;
			txt.defaultTextFormat = format;
			txt.text = title;
			txt.x = txt.height + 6;
			txt.y = 10;
			
			bg.graphics.beginBitmapFill(bg_data);
			bg.graphics.drawRect(0, 0, bg_data.width, bg_data.height);
			
			bg.graphics.beginBitmapFill(op_data);
			bg.graphics.drawRect(0, bg_data.height, bg_data.width, txt.width + 5);
			
			op_data = new BitmapData(bg.width, bg.height + bg_data.height, true, 0x00000000);
			op_data.draw(bg);
			op_data.copyPixels(BitmapUtils.flipVertical(bg_data), new Rectangle(0, 0, bg_data.width, bg_data.height), new Point(0, bg.height));
			
			bg_image = new Bitmap(op_data);
			holder.addChild(bg_image);
			holder.addChild(txt);
			
			txt.rotation = 90;
		}
		public function set direction(value:String):void
		{
			if (value == "left")
			{
				holder.rotation = 180;
				holder.x = holder.width;
				holder.y = holder.height;
			}
			else
			{
				holder.rotation = 0;
				holder.x = 0;
				holder.y = 0;
			}
		}
		override public function get height():Number 
		{
			return bg_image.height;
		}
		
	}

}