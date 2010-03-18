package org.smilkit.dom
{
	import flash.events.EventDispatcher;
	
	import org.smilkit.utils.ObjectManager;
	import org.smilkit.w3c.dom.DOMException;
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.INamedNodeMap;
	import org.smilkit.w3c.dom.INode;
	import org.smilkit.w3c.dom.INodeList;
	
	/**
	 * The base implementation class of any DOM tree, should never be accessed or created directly,
	 * instead it should be extended by a sub-class to include complete methods.
	 * <p>Node also implements INodeList so that it can be used as a list of nodes and be returned
	 * in calls for the children.</p>
	 * 
	 * @see org.smilkit.w3c.dom.INode
	 * @see org.smilkit.w3c.dom.INodeList
	 */
	public class Node extends EventDispatcher implements INode, INodeList
	{
		public static var ELEMENT_NODE:int = 1;
		public static var ATTRIBUTE_NODE:int = 2;
		public static var TEXT_NODE:int = 3;
		public static var CDATA_SECTION_NODE:int = 4;
		public static var ENTITY_REFERENCE_NODE:int = 5;
		public static var ENTITY_NODE:int = 6;
		public static var PROCESSING_INSTRUCTION_NODE:int = 7;
		public static var COMMENT_NODE:int = 8;
		public static var DOCUMENT_NODE:int = 9;
		public static var DOCUMENT_TYPE_NODE:int = 10;
		public static var DOCUMENT_FRAGMENT_NODE:int = 11;
		public static var NOTATION_NODE:int = 12;
		
		protected var _ownerDocument:IDocument = null;
		protected var _parentNode:INode = null;
		
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
			// do nothing, must be sub-classed and extended
		}
		
		public function get nodeType():int
		{
			return 0;
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
		
		/**
		 * Returns a duplicate of the current node instance. The returned 
		 * <code>INode</code> will be a complete new object instance.
		 * 
		 * @param deep Specifies whether to copy all the children. This is ignored as
		 * we don't deal with children in this class.
		 * 
		 * @return New <code>INode</code> copy of the current object instance.
		 */
		public function cloneNode(deep:Boolean):INode
		{
			var newNode:INode = ObjectManager.clone(this) as INode;
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