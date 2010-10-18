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
		
		// When the playhead's offset changes
		public static var PLAYBACK_OFFSET_CHANGED:String = "viewportPlaybackOffsetChanged";
		
		// When the volume is adjusted
		public static var AUDIO_MUTED:String = "viewportAudioMuted";
		public static var AUDIO_UNMUTED:String = "viewportAudioUnmuted";
		public static var AUDIO_VOLUME_CHANGED:String = "viewportAudioVolumeChanged";
		
		// Render tree status events
		public static var WAITING:String = "viewportWaiting";
		public static var READY:String = "viewportReady";
		
		// Document changed internally
		public static var DOCUMENT_MUTATED:String = "viewportDocumentMutated";
		
		// Loader errors
		public static var LOADER_SECURITY_ERROR:String = "viewportLoaderSecurityError";
		public static var LOADER_IOERROR:String = "viewportLoaderIOError";
		
		public function ViewportEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}