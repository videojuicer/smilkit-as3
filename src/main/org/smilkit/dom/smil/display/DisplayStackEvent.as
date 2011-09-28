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
package org.smilkit.dom.smil.display
{
	import flash.events.Event;
	
	import org.smilkit.dom.smil.ElementTimeContainer;
	
	public class DisplayStackEvent extends Event
	{
		public static var ELEMENT_ADDED:String = "displayStackElementAdded";
		public static var ELEMENT_REMOVED:String = "displayStackElementRemoved";

		protected var _element:ElementTimeContainer = null;
		
		public function DisplayStackEvent(type:String, element:ElementTimeContainer, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this._element = element;
		}
		
		public function get element():ElementTimeContainer
		{
			return this._element;
		}
	}
}