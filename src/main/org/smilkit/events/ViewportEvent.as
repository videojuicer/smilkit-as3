/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version 1.1
 * (the "License"); you may not use this file except in compliance with the
 * License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 *
 * The Original Code is the SMILKit library.
 *
 * The Initial Developer of the Original Code is
 * Videojuicer Ltd. (UK Registered Company Number: 05816253).
 * Portions created by the Initial Developer are Copyright (C) 2010
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 * 	Dan Glegg
 * 	Adam Livesley
 *
 * ***** END LICENSE BLOCK ***** */
package org.smilkit.events
{
	import flash.events.Event;
	
	public class ViewportEvent extends Event
	{
		// When loading a new SMIL document
		public static var REFRESH_COMPLETE:String = "viewportRefreshComplete";
		
		// When switching playback states between playing, paused etc.
		public static var PLAYBACK_STATE_CHANGED:String = "viewportPlaybackStateChanged";
		
		// When the playhead's offset changes
		public static var PLAYBACK_OFFSET_CHANGED:String = "viewportPlaybackOffsetChanged";
		
		// When playback has finished playing (aka stopped)
		public static var PLAYBACK_COMPLETE:String = "viewportPlaybackComplete";
		
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
		
		public static var SMIL_PARSE_FAILED:String = "viewportSMILParseFailed";
		
		public static var HANDLER_LOAD_FAILED:String = "renderTreeHandlerLoadFailed";
		public static var HANDLER_LOAD_UNAUTHORISED:String = "renderTreeHandlerLoadUnauthorised";
		
		public function ViewportEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}