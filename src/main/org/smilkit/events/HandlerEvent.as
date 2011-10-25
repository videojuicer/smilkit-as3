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
	
	import org.smilkit.handler.SMILKitHandler;
	
	public class HandlerEvent extends Event
	{
		public static var SEEK_FAILED:String = "handlerSeekFailed";
		public static var SEEK_INVALID:String = "handlerSeekInvalid";
		public static var SEEK_NOTIFY:String = "handlerSeekNotify";
		public static var SEEK_RESULT:String = "handlerSeekResult";
		
		public static var STOP_NOTIFY:String = "handlerStopNotify";
		public static var PAUSE_NOTIFY:String = "handlerPauseNotify";
		public static var RESUME_NOTIFY:String = "handlerResumeNotify";
		
		public static var LOAD_UNAUTHORISED:String = "handlerLoadUnauthorised";
		public static var LOAD_FAILED:String = "handlerLoadFailed";
		
		public static var LOAD_READY:String = "handlerLoadReady";
		public static var LOAD_WAITING:String = "handlerLoadWaiting";
		public static var LOAD_CANCELLED:String = "handlerLoadCancelled";
		public static var LOAD_COMPLETED:String = "handlerLoadCompleted";
		
		public static var DURATION_RESOLVED:String = "handlerDurationResolved";
		
		public static var SELF_MODIFIED:String = "handlerSelfModified";
		
		protected var _handler:SMILKitHandler;
		
		public function HandlerEvent(type:String, handler:SMILKitHandler, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this._handler = handler;
		}
		
		public function get handler():SMILKitHandler
		{
			return this._handler;
		}
	}
}