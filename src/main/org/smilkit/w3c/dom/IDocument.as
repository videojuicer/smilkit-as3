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
{	public interface IDocument extends INode
	{
		function get doctype():IDocumentType;
		function get implementation():IDOMImplementation;
		function get documentElement():IElement;
		
		function createElement(tagName:String):IElement;
		function createDocumentFragment():IDocumentFragment;
		function createTextNode(data:String):IText;
		function createComment(data:String):IComment;
		function createCDATASection(data:String):ICDATASection;
		function createProcessingInstruction(target:String, data:String):IProcessingInstruction;
		function createAttribute(name:String):IAttr;
		function createEntityReference(tagname:String):IEntityReference;
		
		function getElementsByTagName(tagname:String):INodeList;
		function importNode(importedNode:INode, deep:Boolean):INode;
		
		function createElementNS(namespaceURI:String, qualifiedName:String):IElement;
		function createAttributeNS(namespaceURI:String, qualifiedName:String):IAttr;
		
		function getElementsByTagNameNS(namespaceURI:String, localName:String):INodeList;
		
		function getElementById(elementId:String):IElement;
	}
}