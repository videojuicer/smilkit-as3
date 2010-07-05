package org.smilkit.events
{
	import flash.events.Event;
	
	import org.smilkit.time.TimingGraph;
	
	public class ViewportEvent extends Event
	{
		public static var REFRESH_COMPLETE:String = "viewportRefreshComplete";
		public static var PLAYBACK_STATE_CHANGED:String = "viewportStateChanged";
		public static var WAITING_FOR_DATA:String = "viewportWaitingForData";
		public static var READY:String = "viewportReady";
		
		public function ViewportEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}