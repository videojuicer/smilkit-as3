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
	public interface IElementTime
	{
		function get begin():ITimeList;
		function set begin(begin:ITimeList):void;
		
		function get end():ITimeList;
		function set end(end:ITimeList):void;
		
		function get dur():String;
		function set dur(dur:String):void;
		
		function get duration():Number;
		
		function get restart():uint;
		function set restart(restart:uint):void;
		
		function get fill():uint;
		function set fill(fill:uint):void;
		
		function get repeatCount():Number;
		function set repeatCount(repeatCount:Number):void;
		
		function get repeatDur():Number;
		function set repeatDur(repeatDur:Number):void;
		
		function beginElement():Boolean;
		
		function endElement():Boolean;
		
		function pauseElement():void;
		
		function resumeElement():void;
		
		function seekElement(seekTo:Number):void;
	}
}