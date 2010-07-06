package org.smilkit.events
{
	import flash.events.Event;
	
	public class HeartbeatEvent extends Event
	{
		public static var OFFSET_CHANGED:String = "heartbeatOffsetChanged";
		
		protected var _offset:Number;
		
		public function HeartbeatEvent(type:String, offset:Number, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this._offset = offset;
		}
		
		public function get offset():Number
		{
			return this._offset;
		}
	}
}