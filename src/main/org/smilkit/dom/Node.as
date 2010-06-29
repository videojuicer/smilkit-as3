package org.smilkit.dom
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import org.smilkit.util.ObjectManager;
	import org.smilkit.w3c.dom.DOMException;
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.INamedNodeMap;
	import org.smilkit.w3c.dom.INode;
	import org.smilkit.w3c.dom.INodeList;
	import org.smilkit.w3c.dom.events.IEvent;
	import org.smilkit.w3c.dom.events.IEventListener;
	import org.smilkit.w3c.dom.events.IEventTarget;
	
	/**
	 * The base implementation class of any DOM tree, should never be accessed or created directly,
	 * instead it should be extended by a sub-class to include complete methods.
	 * <p>Node also implements INodeList so that it can be used as a list of nodes and be returned
	 * in calls for the children.</p>
	 * 
	 * @see org.smilkit.w3c.dom.INode
	 * @see org.smilkit.w3c.dom.INodeList
	 */
	public class Node implements INode, INodeList
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
			return this._ownerDocument;
		}
		
		private function get coreOwnerDocument():CoreDocument
		{
			return this._ownerDocument as CoreDocument;
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
		
		/**
		 * Returns the number of changes that have occured on this node.
		 */
		public function get changes():int
		{
			return (this._ownerDocument as Document).changes;
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
		
		/**
		 * Add the specified <code>IEventListener</code> to the stack of registered listeners.
		 * 
		 * @param type The event name to listen for.
		 * @param listener The <code>IEventListener</code> to execute when the event is dispatched.
		 * @param useCapture True to register the listener on the capturing phase rather than at-target or bubbling.
		 */
		public function addEventListener(type:String, listener:Function, useCapture:Boolean):void
		{
			this.coreOwnerDocument.addNodeEventListener(this, type, listener, useCapture);
		}
		
		/**
		 * Remove the specified <code>IEventListener</code> from the stack of registered listeners.
		 * 
		 * @param type The event name to listen for.
		 * @param listener The <code>IEventListener</code> to execute when the event is dispatched.
		 * @param useCapture True to register the listener on the capturing phase rather than at-target or bubbling.
		 */
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean):void
		{
			this.coreOwnerDocument.removeNodeEventListener(this, type, listener, useCapture);
		}
		
		/**
		 * Dispatch the specified <code>IEvent</code> through the DOM.
		 * 
		 * @param event The <code>IEvent</code> instance to dispatch.
		 * 
		 * @return Returns <code>true</code> if the event's <code>preventDefault</code> was invoked, otherwise <code>false</code>.
		 */
		public function dispatchEvent(event:IEvent):Boolean
		{
			return this.coreOwnerDocument.dispatchNodeEvent(this, event);
		}
		
		/**
		 * Increments the number of changes on this <code>Node</code>
		 */
		protected function changed():void
		{
			(this._ownerDocument as Document).changed();
		}
	}
}