package  nid.utils
{
	import adobe.utils.CustomActions;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Nidin P Vinayakan
	 */
	public class BitmapUtils 
	{
		
		public function BitmapUtils() 
		{
			
		}
		
		public static function crop(src:BitmapData, x:int, y:int, width:int, height:int) : BitmapData
        {
            var data:BitmapData = new BitmapData(width, height);
            data.copyPixels(src, new Rectangle(x, y, width, height), src.rect.topLeft);
            return data;
        }
		
		public static function cropRect(src:BitmapData, rect:Rectangle) : BitmapData
        {
            var data:BitmapData = new BitmapData(rect.width, rect.height);
            data.copyPixels(src, new Rectangle(rect.x, rect.y, rect.width, rect.height), src.rect.topLeft);
            return data;
        }
		
		public static function Desaturate(bmp_data:BitmapData) : BitmapData
        {
            var _loc_2:uint = 0;
            var _loc_3:int = 0;
            var _loc_4:int = 0;
            var _loc_5:int = 0;
            var _loc_7:int = 0;
            var _loc_6:int = 0;
            while (_loc_6 < bmp_data.width)
            {
                
                _loc_7 = 0;
                while (_loc_7 < bmp_data.height)
                {
                    
                    _loc_2 = bmp_data.getPixel(_loc_6, _loc_7);
                    _loc_3 = _loc_2 >>> 16 & 255;
                    _loc_4 = _loc_2 >>> 8 & 255;
                    _loc_5 = _loc_2 & 255;
                    var _loc_8:* = 0.299 * _loc_3 + 0.587 * _loc_4 + 0.114 * _loc_5;
                    _loc_5 = 0.299 * _loc_3 + 0.587 * _loc_4 + 0.114 * _loc_5;
                    _loc_4 = _loc_8;
                    _loc_3 = _loc_8;
                    bmp_data.setPixel(_loc_6, _loc_7, _loc_3 << 16 | _loc_4 << 8 | _loc_5);
                    _loc_7++;
                }
                _loc_6++;
            }
            return bmp_data;
        }
		public static function flipHorizontal(src:BitmapData):BitmapData
		{
			var data:BitmapData = new BitmapData(src.width, src.height);
			
			for (var h:int = 0; h < src.height; h++)
			{
				for (var w:int = src.width; w > 0; w--)
				{
					if (src.transparent)
					{
						data.setPixel32(w - 1, h, src.getPixel32(src.width - w, h));
					}
					else
					{
						data.setPixel(w - 1, h, src.getPixel(src.width - w, h));
					}
				}
			}
			
			return data;
		}
		public static function flipVertical(src:BitmapData):BitmapData
		{
			var data:BitmapData = new BitmapData(src.width, src.height);
			
			for (var w:int = 0; w < src.width; w++)
			{
				for (var h:int = src.height; h > 0; h--)
				{
					if (src.transparent)
					{
						data.setPixel32(w, h - 1, src.getPixel32(w,src.height -  h));
					}
					else
					{
						data.setPixel(w, h - 1, src.getPixel(w, src.height - h));
					}
				}
			}
			
			return data;
		}
		
		public static function expandX(src:BitmapData, src_rect:Rectangle, tar_rect:Rectangle):BitmapData
		{
			var data:BitmapData = new BitmapData(tar_rect.width, tar_rect.height, false, 0x00000000);
			
			for (var i:int = 0; i < Math.ceil(tar_rect.width / src_rect.width); i++)
			{
				data.copyPixels(src, src_rect, new Point(i * src_rect.width, 0));
			}
			
			return data;
		}
		public static function expandY(src:BitmapData, src_rect:Rectangle, tar_rect:Rectangle):BitmapData
		{
			var data:BitmapData = new BitmapData(tar_rect.width, tar_rect.height, false, 0x00000000);
			
			for (var i:int = 0; i < Math.ceil(tar_rect.height / src_rect.height); i++)
			{
				data.copyPixels(src, src_rect, new Point(0, i * src_rect.height));
			}
			
			return data;
		}
		public static function expandXY(src:BitmapData, src_rect:Rectangle, tar_rect:Rectangle):BitmapData
		{
			var data:BitmapData = new BitmapData(tar_rect.width, tar_rect.height, false, 0x00000000);
			
			for (var i:int = 0; i < Math.ceil(tar_rect.width / src_rect.width); i++)
			{
				data.copyPixels(src, src_rect, new Point(i * src_rect.width, 0));
				
				for (var j:int = 0; j < Math.ceil(tar_rect.height / src_rect.height); j++)
				{
					data.copyPixels(src, src_rect, new Point(i * src_rect.width, j * src_rect.height));
				}
			}
			
			return data;
		}
	}

}