package nid 
{
	import flash.display.Shape;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Nidin P Vinayakan
	 */
	public class Preloader extends Sprite 
	{
		public var bg:Shape;
		public var bar:Shape;
		
		public function Preloader() 
		{
			configUI();
		}
		
		private function configUI():void 
		{
			bg = new Shape();
			bg.graphics.beginFill(0xCCCCCC);
			bg.graphics.drawRect(0, 0, 100, 2);
			bg.graphics.endFill();
			addChild(bg);
			
			bar = new Shape();
			bar.graphics.beginFill(0x333333);
			bar.graphics.drawRect(0, 0, 100, 2);
			bar.graphics.endFill();
			addChild(bar);
			bar.width = 1;
		}
		public function progress(percent:int):void
		{
			bar.width = percent;
		}
	}

}