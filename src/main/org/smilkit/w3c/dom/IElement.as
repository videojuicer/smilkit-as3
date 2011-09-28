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
	public interface IElement extends INode
	{
		function get tagName():String;
		
		function getAttribute(name:String):String;
		function setAttribute(name:String, value:String):void;
		function removeAttribute(name:String):void;
		
		function getAttributeNode(name:String):IAttr;
		function setAttributeNode(newAttr:IAttr):IAttr;
		function removeAttributeNode(oldAttr:IAttr):IAttr;
		
		function getElementsByTagName(name:String):INodeList;

		function getAttributeNS(namespaceURI:String, localName:String):Object;
		function setAttributeNS(namespaceURI:String, qualifiedName:String, value:String):void;
		function removeAttributeNS(namespaceURI:String, localName:String):void;
		
		function getAttributeNodeNS(namespaceURI:String, localName:String):IAttr;
		function setAttributeNodeNS(newAttr:IAttr):IAttr;
		function removeAttributeNodeNS(oldAttr:IAttr):IAttr;
		
		function getElementsByTagNameNS(namespaceURI:String, localName:String):INodeList;
		
		function hasAttribute(name:String):Boolean;
		function hasAttributeNS(namespaceURI:String, localName:String):Boolean;
	}
}