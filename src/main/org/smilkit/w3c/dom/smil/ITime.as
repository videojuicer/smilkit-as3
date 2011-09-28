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
	import org.smilkit.w3c.dom.INode;

	public interface ITime
	{
		function get resolved():Boolean;

		function get resolvedOffset():Number;
		
		function get timeType():uint;

		function get offset():Number;
		//function set offset(offset:Number):void;
		
		function get baseElement():INode;
		//function set baseElement(baseElement:INode):void;
		
		function get baseBegin():Boolean;
		//function set baseBegin(baseBegin:Boolean):void;
		
		function get event():String;
		//function set event(event:String):void;
		
		function get marker():String;
		//function set marker(marker:String):void;
	}
}