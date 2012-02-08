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
	
	import org.smilkit.dom.smil.ElementTimeContainer;
	import org.smilkit.handler.SMILKitHandler;

	public class HandlerControllerEvent extends Event
	{
		public static var ELEMENT_REMOVED:String = "renderTreeElementRemoved";
		public static var ELEMENT_ADDED:String = "renderTreeElementAdded";
		public static var ELEMENT_REPLACED:String = "renderTreeElementReplaced";
		public static var ELEMENT_MODIFIED:String = "renderTreeElementModified";		
		public static var ELEMENT_STOPPED:String = "renderTreeElementStopped";
		
		public static var READY:String = "renderTreeReady";
		public static var WAITING_FOR_DATA:String = "renderTreeWaitingForData";
		public static var WAITING_FOR_SYNC:String = "renderTreeWaitingForSync";
		
		public static var HANDLER_LOAD_FAILED:String = "renderTreeHandlerLoadFailed";
		public static var HANDLER_LOAD_UNAUTHORISED:String = "renderTreeHandlerLoadUnauthorised";
		
		protected var _handler:SMILKitHandler;
		
		public function HandlerControllerEvent(type:String, element:SMILKitHandler, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this._handler = element;
		}
		
		public function get handler():SMILKitHandler
		{
			return this._handler;
		}
		
		public override function clone():Event
		{
			return new HandlerControllerEvent(this.type, this.handler, this.bubbles, this.cancelable);
		}
	}
}