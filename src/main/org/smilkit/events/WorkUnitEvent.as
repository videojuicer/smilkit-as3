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
	
	public class WorkUnitEvent extends Event
	{
		public static var WORK_UNIT_QUEUED:String = "workUnitQueued"; // Dispatched when an item is added to the worker's queue
		public static var WORK_UNIT_LISTED:String = "workUnitListed"; // Dispatched when an item is moved to the worklist
		public static var WORK_UNIT_REMOVED:String = "workUnitRemoved"; // Dispatched when an item is removed from either list by imperative.
		
		public static var WORK_UNIT_COMPLETED:String = "workUnitCompleted"; // Dispatched when the completion event on a handler is received
		public static var WORK_UNIT_FAILED:String = "workUnitFailed"; // Dispatched when the failure event on a handler is received
		
		protected var _handler:SMILKitHandler;
		
		public function WorkUnitEvent(type:String, handler:SMILKitHandler, bubbles:Boolean=false, cancelable:Boolean=false)
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