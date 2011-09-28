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
package org.smilkit.handler.state
{
	import org.utilkit.parser.URLParser;

	public class HandlerState
	{
		protected var _src:String;
		protected var _handlerOffset:int;
		
		protected var _extractedSrc:URLParser;
		
		public function HandlerState(src:String, handlerOffset:int)
		{
			this._src = src;
			this._handlerOffset = handlerOffset;
			
			this._extractedSrc = new URLParser(this._src);
		}
		
		public function get src():String
		{
			return this._src;
		}
		
		public function get extractedSrc():URLParser
		{
			return this._extractedSrc;
		}
		
		public function get handlerOffset():int
		{
			return this._handlerOffset;
		}
		
		public function get type():String
		{
			return "generic";
		}
		
		public function compatibleWith(handlerState:HandlerState):Boolean
		{
			if (this.type == handlerState.type)
			{
				if (this.extractedSrc.protocol == handlerState.extractedSrc.protocol)
				{
					return true;
				}
			}
			
			return false;
		}
	}
}