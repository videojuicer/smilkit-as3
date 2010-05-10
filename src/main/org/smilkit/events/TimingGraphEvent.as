package org.smilkit.events
{
	import flash.events.Event;

	public class TimingGraphEvent extends Event
	{
		public static var REBUILD:String = "timingGraphRebuild";
		public static var ELEMENT_ADDED:String = "timingGraphElementAdded";
		
		public function TimingGraphEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}