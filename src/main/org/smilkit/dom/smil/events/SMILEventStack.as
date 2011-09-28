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
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.dom.smil.SMILElement;
	import org.utilkit.collection.Hashtable;

	public class SMILEventStack
	{
		public static var SMILELEMENT_BEGIN:String = "beginEvent";
		public static var SMILELEMENT_END:String = "endEvent";
		public static var SMILELEMENT_REPEAT:String = "repeatEvent";
		
		protected var _document:SMILDocument = null;
		protected var _triggeredStack:Hashtable = null;
		
		public function SMILEventStack(document:SMILDocument)
		{
			this._document = document;
			
			this.clear();
		}
		
		public function triggerEvent(element:SMILElement, eventName:String):void
		{
			var events:Hashtable = new Hashtable();
			
			if (this._triggeredStack.hasItem(element))
			{
				events = this._triggeredStack.getItem(element);
			}
			
			events.setItem(eventName, this._document.offset);
			
			this._triggeredStack.setItem(element, events);
		}
		
		public function hasEventTriggered(element:SMILElement, eventName:String):Boolean
		{
			if (this._triggeredStack.hasItem(element))
			{
				var events:Hashtable = this._triggeredStack.getItem(element);
				
				if (events.hasItem(eventName))
				{
					return true;
				}
			}
			
			return false;
		}
		
		public function getTriggeredOffset(element:SMILElement, eventName:String):Number
		{
			if (this._triggeredStack.hasItem(element))
			{
				var events:Hashtable = this._triggeredStack.getItem(element);
				
				if (events.hasItem(eventName))
				{
					return events.getItem(eventName);
				}
			}
			
			return 0;
		}
		
		public function clear():void
		{
			this._triggeredStack = new Hashtable();
		}
	}
}