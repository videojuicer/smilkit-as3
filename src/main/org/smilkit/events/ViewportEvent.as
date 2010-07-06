package org.smilkit.events
{
	import flash.events.Event;
	
	import org.smilkit.time.TimingGraph;
	
	public class ViewportEvent extends Event
	{
		// When loading a new SMIL document
		public static var REFRESH_COMPLETE:String = "viewportRefreshComplete";
		
		// When switching playback states between playing, paused etc.
		public static var PLAYBACK_STATE_CHANGED:String = "viewportPlaybackStateChanged";
		
		// Load status events
		public static var WAITING_FOR_DATA:String = "viewportWaitingForData";
		public static var READY:String = "viewportReady";
		
		// Document changed internally
		public static var DOCUMENT_MUTATED:String = "viewportDocumentMutated";
		
		public function ViewportEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}