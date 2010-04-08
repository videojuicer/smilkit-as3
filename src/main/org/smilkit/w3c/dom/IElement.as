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