package org.smilkit.events
{
	import flash.events.Event;
	
	import org.smilkit.time.TimingGraph;
	
	public class ViewportEvent extends Event
	{
		public static var REFRESH_COMPLETE:String = "viewportRefreshComplete";
		
		public function ViewportEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}