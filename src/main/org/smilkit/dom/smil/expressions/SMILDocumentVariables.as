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
package org.smilkit.dom.smil.expressions
{
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.dom.smil.events.SMILMutationEvent;
	import org.utilkit.collection.Hashtable;

	public class SMILDocumentVariables
	{
		public static const SYSTEM_BITRATE:String = "systemBitrate";
		public static const SYSTEM_CAPTIONS:String = "systemCaptions";
		public static const SYSTEM_LANGUAGE:String = "systemLanguage";
		public static const SYSTEM_OVERDUB_OR_CAPTION:String = "systemOverdubOrCaption";
		public static const SYSTEM_REQUIRED:String = "systemRequired";
		public static const SYSTEM_SCREEN_SIZE:String = "systemScreenSize";
		public static const SYSTEM_SCREEN_DEPTH:String = "systemScreenDepth";
		public static const SYSTEM_OVERDUB_OR_SUBTITLE:String = "systemOverdubOrSubtitle";
		public static const SYSTEM_AUDIO_DESC:String = "systemAudioDesc";
		public static const SYSTEM_OPERATING_SYSTEM:String = "systemOperatingSystem";
		public static const SYSTEM_CPU:String = "systemCPU";
		public static const SYSTEM_CONTENT_LOCATION:String = "systemContentLocation";
		public static const SYSTEM_COMPONENT:String = "systemComponent";
		
		public static const SYSTEM_BASE_PROFILE:String = "systemBaseProfile";
		public static const SYSTEM_VERSION:String = "systemVersion";
		
		protected var _hash:Hashtable;
		protected var _document:SMILDocument;
		
		public function SMILDocumentVariables(document:SMILDocument)
		{
			this._document = document;
			
			this._hash = new Hashtable();
		}
		
		public function get(name:String):Object
		{
			return this._hash.getItem(name);
		}
		
		public function set(name:String, value:Object):void
		{
			var event:SMILMutationEvent = new SMILMutationEvent();

			var previousValue:Object = this.get(name);
			
			if (previousValue != null)
			{
				if (value == null)
				{
					// removed
					this._hash.removeItem(name);
					
					event.initMutationEvent(SMILMutationEvent.DOM_VARIABLES_REMOVED, true, false, null, new String(previousValue), new String(value), name, 1);
				}
				else
				{
					// modified
					this._hash.setItem(name, value);
					
					event.initMutationEvent(SMILMutationEvent.DOM_VARIABLES_MODIFIED, true, false, null, new String(previousValue), new String(value), name, 1);
				}
			}
			else
			{
				// inserted
				this._hash.setItem(name, value);
				
				event.initMutationEvent(SMILMutationEvent.DOM_VARIABLES_INSERTED, true, false, null, new String(previousValue), new String(value), name, 1);
			}
			
			this._document.dispatchEvent(event);
		}
	}
}