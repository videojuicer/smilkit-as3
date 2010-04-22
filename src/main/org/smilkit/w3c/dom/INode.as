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