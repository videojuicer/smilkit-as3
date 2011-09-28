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
	public class ListenerEntry
	{
		private var _type:String;
		private var _listener:Function;
		private var _useCapture:Boolean;
			
		public function ListenerEntry(type:String, listener:Function, useCapture:Boolean)
		{
			this._type = type;
			this._listener = listener;
			this._useCapture = useCapture;
		}
		
		public function get type():String
		{
			return this._type;
		}
		
		public function get listener():Function
		{
			return this._listener;
		}
		
		public function get useCapture():Boolean
		{
			return this._useCapture;
		}
	}
}