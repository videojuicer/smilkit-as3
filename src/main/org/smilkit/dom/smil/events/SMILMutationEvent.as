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
		
		public static var DOM_NODE_RENDER_STATE_MODIFIED:String = "DOMNodeRenderStateModified";
	}
}