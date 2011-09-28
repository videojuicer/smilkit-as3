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
	public interface ISMILMediaElement extends IElementTime, ISMILElement
	{
		function get abstractAttr():String;
		function set abstractAttr(abstractAttr:String):void;
		
		function get alt():String;
		function set alt(alt:String):void;
		
		function get author():String;
		function set author(author:String):void;
		
		function get clipBegin():String;
		function set clipBegin(clipBegin:String):void;
		
		function get clipEnd():String;
		function set clipEnd(clipEnd:String):void;
		
		function get copyright():String;
		function set copyright(copyright:String):void;
		
		function get longdesc():String;
		function set longdesc(longdesc:String):void;
		
		function get port():String;
		function set port(port:String):void;
		
		function get readIndex():String;
		function set readIndex(readIndex:String):void;
		
		function get rtpFormat():String;
		function set rtpFormat(rtpFormat:String):void;
		
		function get src():String;
		function set src(src:String):void;
		
		function get stripRepeat():String;
		function set stripRepeat(stripRepeat:String):void;
		
		function get title():String;
		function set title(title:String):void;
		
		function get transport():String;
		function set transport(transport:String):void;
		
		function get type():String;
		function set type(type:String):void;
		
		function get params():Object;
		function getParam(name:String):String;
		function setParam(name:String, value:String):void;
	}
}