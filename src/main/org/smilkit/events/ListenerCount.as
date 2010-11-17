package org.smilkit.events
{
	import org.utilkit.collection.Hashtable;

	public class ListenerCount
	{
		private static var __listenerCounts:Hashtable = new Hashtable();
		
		private var _captures:int = 0;
		private var _bubbles:int = 0;
		private var _defaults:int;
		private var _total:int = 0;
		
		public static function lookup(eventName:String):ListenerCount
		{
			var count:ListenerCount = ListenerCount.__listenerCounts.getItem(eventName) as ListenerCount;
			
			if (count == null)
			{
				count = new ListenerCount();
				ListenerCount.__listenerCounts.setItem(eventName, count);
			}
			
			return count;
		}
		
		public function get captures():int
		{
			return this._captures;
		}
		
		public function set captures(value:int):void
		{
			this._captures = value;
		}
		
		public function get bubbles():int
		{
			return this._bubbles;
		}
		
		public function set bubbles(value:int):void
		{
			this._bubbles = value;
		}
		
		public function get defaults():int
		{
			return this._defaults;
		}
		
		public function set defaults(value:int):void
		{
			this._defaults = value;
		}
		
		public function get total():int
		{
			return this._total;
		}
		
		public function set total(value:int):void
		{
			this._total = value;
		}
	}
}