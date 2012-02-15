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
package org.smilkit
{
	CONFIG::USE_SMILKIT import org.smilkit.handler.HandlerMap;
	CONFIG::USE_SMILKIT import org.smilkit.view.Viewport;
	
	CONFIG::USE_OSMF import org.smilkit.view.OSMFViewport;
	
	import org.utilkit.logger.ApplicationLog;
	import org.utilkit.logger.Logger;
	import org.smilkit.view.BaseViewport;
	
	/**
	 * SMILKit's main static API object, allows the creation, manipulation and browsing of SMIL3.0 DOM documents.
	 * 
	 * Implements the W3C DOM Level 2 specification and SMIL 3.0 Boston DOM specification.
	 * 
	 * @see http://www.w3.org/TR/2000/REC-DOM-Level-2-Views-20001113
	 * @see http://www.w3.org/TR/smil-boston-dom/
	 */
	public class SMILKit
	{
		private static const __version:String = "0.4.1";
		private static const __applicationLog:ApplicationLog = new ApplicationLog("smilkit-as3");
		
		public static const ACTIVATION_NUDGE:int = 1; // SharedTimer.DELAY;
		
		/**
		 * Retrieve's the current SMILKit version.
		 */
		public static function get version():String
		{
			return SMILKit.__version;
		}
		
		public static function get logger():ApplicationLog
		{
			return SMILKit.__applicationLog;
		}
		
		/**
		 * Create's a new empty SMILKit <code>Viewport</code>.
		 * 
		 * @return The generated <code>Viewport</code>.
		 * 
		 * @see org.smilkit.view.Viewport
		 */
		public static function createEmptyViewport():BaseViewport
		{
			var viewport:BaseViewport = null;
			
			CONFIG::USE_OSMF { viewport = new OSMFViewport(); };
			CONFIG::USE_SMILKIT { viewport = new Viewport(); };
			
			return viewport;
		}
		
		/**
		 * Register the default setup for SMILKit.
		 */
		public static function defaults():void
		{
			// load default logger renderers
			Logger.defaultRenderers();
			
			// load the default smilkit handlers
			CONFIG::USE_SMILKIT { HandlerMap.defaultHandlers(); }
		}
	}
}