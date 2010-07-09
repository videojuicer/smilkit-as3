package org.smilkit.events
{
	import flash.events.Event;
	
	public class HeartbeatEvent extends Event
	{
		public static var RESUMED:String = "heartbeatResumed";
		public static var PAUSED:String = "heartbeatPaused";
		public static var OFFSET_CHANGED:String = "heartbeatOffsetChanged";
		
		protected var _runningOffset:Number;
		
		public function HeartbeatEvent(type:String, runningOffset:Number, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this._runningOffset = runningOffset;
		}
		
		public function get runningOffset():Number
		{
			return this._runningOffset;
		}
	}
}