package org.smilkit.dom.smil.events
{
	import org.smilkit.dom.events.MutationEvent;

	/**
	 * Describes SMIL DOM mutation events, expands from the standard DOM <code>MutationEvent</code>
	 * to include new events introduced with SMILKit.
	 */
	public class SMILMutationEvent extends MutationEvent
	{
		// DOM Variables extension on the SMIL Boston DOM
		public static var DOM_VARIABLES_MODIFIED:String = "DOMVariablesModified";
		public static var DOM_VARIABLES_INSERTED:String = "DOMVariablesInserted";
		public static var DOM_VARIABLES_REMOVED:String = "DOMVariablesRemoved";
		
		// DOM Playback state extension
		public static var DOM_PLAYBACK_STATE_MODIFIED:String = "DOMPlaybackStateModified";
		
		// DOM Time Graph
		public static var DOM_TIMEGRAPH_MODIFIED:String = "DOMTimeGraphModified";
		
		public static var DOM_CURRENT_INTERVAL_MODIFIED:String = "DOMCurrentIntervalModified";
	}
}