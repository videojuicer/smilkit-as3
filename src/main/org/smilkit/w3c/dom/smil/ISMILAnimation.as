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
package org.smilkit.w3c.dom.smil
{
	public interface ISMILAnimation extends ISMILElement, IElementTargetAttributes, IElementTime, IElementTimeControl
	{
		function get additive():int;
		function set additive(additive:int):void;
		
		function get accumulate():int;
		function set accumulate(accumulate:int):void;
		
		function get calcMode():int;
		function set calcMode(calcMode:int):void;
		
		function get keySplines():String;
		function set keySplines(keySplines:String):void;
		
		function get keyTimes():ITimeList;
		function set keyTimes(keyTimes:ITimeList):void;
		
		function get values():String;
		function set values(values:String):void;
		
		function get from():String;
		function set from(from:String):void;
		
		function get to():String;
		function set to(to:String):void;
		
		function get by():String;
		function set by(by:String):void;
	}
}