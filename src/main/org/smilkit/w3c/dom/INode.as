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
package org.smilkit.w3c.dom
{
	import org.smilkit.w3c.dom.events.IEvent;
	import org.smilkit.w3c.dom.events.IEventTarget;
	import org.smilkit.w3c.dom.events.IEventListener;

	/**
	 * @see org.smilkit.dom.Node
	 * @see Document Object Model (DOM) Level 2 Views Specification: http://www.w3.org/TR/2000/REC-DOM-Level-2-Views-20001113
	 */
	public interface INode extends IEventTarget
	{
		function get nodeName():String;
		function get nodeValue():String;
		function set nodeValue(nodeValue:String):void;
		function get nodeType():int;
		function get parentNode():INode;
		function get childNodes():INodeList;
		function get firstChild():INode;
		function get lastChild():INode;
		function get previousSibling():INode;
		function get nextSibling():INode;
		function get attributes():INamedNodeMap;
		function get ownerDocument():IDocument;
		function get localName():String;
		function get prefix():String;
		function set prefix(prefix:String):void;
		function get namespaceURI():String;
		
		function insertBefore(newChild:INode, refChild:INode):INode;
		function replaceChild(newChild:INode, oldChild:INode):INode;
		function removeChild(oldChild:INode):INode;
		function appendChild(newChild:INode):INode;
		
		function hasChildNodes():Boolean;
		function cloneNode(deep:Boolean):INode;
		function normalize():void;
		
		function isSupported(feature:String, version:String):Boolean;
		function hasAttributes():Boolean;
	}
}