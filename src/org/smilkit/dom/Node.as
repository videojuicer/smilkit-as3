package org.smilkit.dom
{
	import flash.events.EventDispatcher;
	
	import org.smilkit.utils.CloneHelper;
	import org.smilkit.w3c.dom.DOMException;
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.INamedNodeMap;
	import org.smilkit.w3c.dom.INode;
	import org.smilkit.w3c.dom.INodeList;
	
	/**
	 * The base implementation class of any DOM tree, should never be accessed or created directly,
	 * instead it should be extended by a sub-class to include complete methods.
	 * 
	 * @see org.smilkit.w3c.dom.INode
	 * @see org.smilkit.w3c.dom.INodeList
	 */
	public class Node extends EventDispatcher implements INode, INodeList
	{
		private var _ownerDocument:IDocument = null;
		private var _parentNode:INode = null;
		
		private var _nextSibling:INode = null;
		private var _previousSibling:INode = null;
		
		public function Node(owner:IDocument = null)
		{
			super();
			
			if (owner != null)
			{
				this._ownerDocument = owner;
			}
		}
		
		public function get nodeName():String
		{
			return null;
		}
		
		public function get nodeValue():String
		{
			return null;
		}
		
		public function set nodeValue(nodeValue:String):void
		{
		}
		
		public function get nodeType():String
		{
			return null;
		}
		
		public function get parentNode():INode
		{
			return null;
		}
		
		public function get childNodes():INodeList
		{
			return null;
		}
		
		public function get firstChild():INode
		{
			return null;
		}
		
		public function get lastChild():INode
		{
			return null;
		}
		
		public function get previousSibling():INode
		{
			return null;
		}
		
		public function get nextSibling():INode
		{
			return null;
		}
		
		public function get attributes():INamedNodeMap
		{
			return null;
		}
		
		public function get ownerDocument():IDocument
		{
			return null;
		}
		
		public function get localName():String
		{
			return null;
		}
		
		public function get prefix():String
		{
			return null;
		}
		
		public function set prefix(prefix:String):void
		{
		}
		
		public function get namespaceURI():String
		{
			return null;
		}
		
		public function get length():int
		{
			return 0;
		}
		
		public function item(index:int):INode
		{
			return null;
		}
		
		public function insertBefore(newChild:INode, refChild:INode):INode
		{
			throw new DOMException(DOMException.HIERARCHY_REQUEST_ERR, DOMMessageFormatter.formatMessage(DOMMessageFormatter.DOM_DOMAIN, "HIERARCHY_REQUEST_ERR")); 
		}
		
		public function replaceChild(newChild:INode, oldChild:INode):INode
		{
			throw new DOMException(DOMException.HIERARCHY_REQUEST_ERR, DOMMessageFormatter.formatMessage(DOMMessageFormatter.DOM_DOMAIN, "HIERARCHY_REQUEST_ERR"));
		}
		
		public function removeChild(oldChild:INode):INode
		{
			throw new DOMException(DOMException.NOT_FOUND_ERR, DOMMessageFormatter.formatMessage(DOMMessageFormatter.DOM_DOMAIN, "NOT_FOUND_ERR"));
		}
		
		public function appendChild(newChild:INode):INode
		{
			return this.insertBefore(newChild, null);
		}
		
		public function hasChildNodes():Boolean
		{
			return false;
		}
		
		public function cloneNode(deep:Boolean):INode
		{
			var newNode:INode = CloneHelper.clone(this) as INode;
			
			// should fire NODE_CLONED event
			
			return newNode;
		}
		
		public function normalize():void
		{
		}
		
		public function isSupported(feature:String, version:String):Boolean
		{
			return false;
		}
		
		public function hasAttributes():Boolean
		{
			return false;
		}
	}
}