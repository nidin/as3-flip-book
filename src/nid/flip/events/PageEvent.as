package nid.flip.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Nidin P Vinayakan
	 */
	public class PageEvent extends Event 
	{
		public static const BOOK_MARK:String = "book_mark";
		
		public var data:Object;
		public function get index():int { return data.index; }
		public function get side():String { return data.side; }
		
		public function PageEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false)
		{ 
			this.data = data;
			super(type, bubbles, cancelable);
		}
	}
	
}