package org.smilkit.w3c.dom
{
	public interface INamedNodeMap
	{
		function get length():int;
		
		function getNamedItem(name:String):INode;
		function setNamedItem(arg:INode):INode;
		function removeNamedItem(name:String):INode;
		function item(index:int):INode;
		function getNamedItemNS(namespaceURI:String, localName:String):INode;
		function setNamedItemNS(arg:INode):INode;
		function removeNamedItemNS(namespaceURI:String, localName:String):INode;
	}
}