package org.smilkit.w3c.dom
{
	public interface INode
	{
		function get nodeName():String;
		function get nodeValue():String;
		function set nodeValue(nodeValue:String):void;
		function get nodeType():String;
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