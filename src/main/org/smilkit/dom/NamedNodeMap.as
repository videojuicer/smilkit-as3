package org.smilkit.dom
{
	import org.smilkit.util.HashMap;
	import org.smilkit.w3c.dom.DOMException;
	import org.smilkit.w3c.dom.INamedNodeMap;
	import org.smilkit.w3c.dom.INode;
	
	/**
	 * Describes a collection of <code>Nodes</code> that can be accessed by name. Entity, Notation are placed
	 * in a <code>NamedNodeMap</code> to allow access via name. Attributes also use a <code>NamedNodeMap</code>
	 * but use the sub-class <code>AttributeMap</code> to provide more functionality.
	 *
	 * @see org.smilkit.dom.AttributeMap
	 */
	public class NamedNodeMap implements INamedNodeMap
	{
		protected var _nodes:HashMap;
		protected var _ownerNode:INode;
		
		public function NamedNodeMap(ownerNode:INode)
		{
			this._ownerNode = ownerNode;
		}
		
		/**
		 * Returns the number of nodes currently stored in this <code>NamedNodeMap</code> instance.
		 */
		public function get length():int
		{
			return (this._nodes != null ? this._nodes.length : 0);
		}
		
		/**
		 * Retrieves an <code>INode</code> from the specified name.
		 * 
		 * @param name Name of the node to find.
		 * 
		 * @return The <code>INode</code> instance that matches the specified name or null
		 * if a match could not be found.
		 */
		public function getNamedItem(name:String):INode
		{
			var i:int = this.locateNamedNode(name, 0);
			return (i < 0) ? null : this.item(i);
		}
		
		/**
		 * Add's a new <code>INode</code> instance to the list or updates the existing node by
		 * matching on the name.
		 * 
		 * @param arg The <code>INode</code> instance to store in the list. The node will then be accessible
		 * via a named item search.
		 * 
		 * @return If the new <code>INode</code> instance is used to replace an existing node, the old <code>INode</code>
		 * instance will be returned. Otherwise the result is null.
		 */
		public function setNamedItem(arg:INode):INode
		{
			if (arg.ownerDocument != this._ownerNode.ownerDocument) {
				var msg:String = DOMMessageFormatter.formatMessage(DOMMessageFormatter.DOM_DOMAIN, "WRONG_DOCUMENT_ERR");
				throw new DOMException(DOMException.WRONG_DOCUMENT_ERR, msg);
			}
			
			var i:int = this.locateNamedNode(arg.nodeName, 0);
			var node:Node = null;
			
			if (i >= 0) {
				node = this._nodes[i];
				this._nodes.setItemAt(arg, i);
			} else {
				i = -1 - i;
				if (this._nodes == null) {
					this._nodes = new HashMap();
				}
				
				this._nodes.addItemAt(arg, i);
			}
			
			return node;
		}
		
		/**
		 * Removes the <code>INode</code> instance that matches the name.
		 * 
		 * @param name Name of the node to be removed.
		 * 
		 * @return The <code>INode</code> that was removed or null if the node was not found from the specified name.
		 */
		public function removeNamedItem(name:String):INode
		{
			var i:int = this.locateNamedNode(name, 0);
			if (i < 0) {
				var msg:String = DOMMessageFormatter.formatMessage(DOMMessageFormatter.DOM_DOMAIN, "NOT_FOUND_ERR");
				throw new DOMException(DOMException.NOT_FOUND_ERR, msg);
			}
			
			var node:INode = (this.item(i) as INode);
			this._nodes.removeItemAt(i);
			
			return node;
		}
		
		/**
		 * Returns the specified <code>INode</code> instance from the list by a 0-based index.
		 * 
		 * @param index The item index to retrieve, the contents of the list is not guaranteed to be
		 * stable or to keep the order. Never assume the index always matches the same <code>INode</code> as
		 * items can be added, removed or changed.
		 * 
		 * @return The <code>INode</code> instance which currenty exists on the specified index or null if
		 * the index does not exist.
		 */
		public function item(index:int):INode
		{
			return (this._nodes != null && index < this._nodes.length ? (this._nodes.getItemAt(index) as INode) : null);
		}
		
		/**
		 * Retrieves an <code>INode</code> from the specified <code>namespaceURI</code> and <code>localName</code>.
		 * 
		 * @param namespaceURI The namespace URI of the node to retrieve.
		 * @param localName The local name of the node to retrieve.
		 * 
		 * @return The <code>INode</code> instance that matches the specified <code>namespaceURI</code> and <code>localName</code> or null
		 * if a match could not be found.
		 */
		public function getNamedItemNS(namespaceURI:String, localName:String):INode
		{
			var i:int = this.locateNamedNodeNS(namespaceURI, localName, 0);
			return (i < 0) ? null : this.item(i);
		}
		
		/**
		 * Add's a new <code>INode</code> instance to the list or updates the existing node by
		 * matching on the <code>namespaceURI</code> and <code>localName</code>.
		 * 
		 * @param arg The <code>INode</code> instance to store in the list. The node will then be accessible
		 * via a named namespaced item search.
		 * 
		 * @return If the new <code>INode</code> instance is used to replace an existing node, the old <code>INode</code>
		 * instance will be returned. Otherwise the result is null.
		 */
		public function setNamedItemNS(arg:INode):INode
		{
			if (arg.ownerDocument != this._ownerNode) {
				var msg:String = DOMMessageFormatter.formatMessage(DOMMessageFormatter.DOM_DOMAIN, "WRONG_DOCUMENT_ERR");
				throw new DOMException(DOMException.WRONG_DOCUMENT_ERR, msg);
			}
			
			var i:int = this.locateNamedNodeNS(arg.namespaceURI, arg.localName, 0);
			var node:Node = null;
			
			if (i >= 0) {
				node = this._nodes[i];
				this._nodes.setItemAt(arg, i);
			} else {
				i = -1 - i;
				if (this._nodes == null) {
					this._nodes = new HashMap();
				}
				
				this._nodes.addItemAt(arg, i);
			}
			
			return node;
		}
		
		/**
		 * Removes the <code>INode</code> instance that matches the <code>namespaceURI</code> and <code>localName</code>.
		 * 
		 * @param namespaceURI The namespace URI of the node to remove.
		 * @param localName The local name of the node to remove.
		 * 
		 * @return The <code>INode</code> that was removed or null if the node was not found from the
		 * specified <code>namespaceURI</code> and <code>localName</code>.
		 */
		public function removeNamedItemNS(namespaceURI:String, localName:String):INode
		{
			var i:int = this.locateNamedNodeNS(namespaceURI, localName, 0);
			if (i < 0) {
				var msg:String = DOMMessageFormatter.formatMessage(DOMMessageFormatter.DOM_DOMAIN, "NOT_FOUND_ERR");
				throw new DOMException(DOMException.NOT_FOUND_ERR, msg);
			}
			
			var node:INode = this.getNamedItemNS(namespaceURI, localName);
			this._nodes.removeItemAt(i);
			
			return node;
		}
		
		/**
		 * Locates a node from the <code>HashMap</code> from the specified start point by <code>name</code>.
		 *
		 * @param name Name of the <code>INode</code> to retrieve.
		 * @param start 0-based index to start the search from.
		 * 
		 * @return <code>INode</code> instance of the matched node.
		 */
		protected function locateNamedNode(name:String, start:int):int {
			var i:int = 0;
			
			if (this._nodes != null) {
				var first:int = start;
				var last:int = this.length - 1;
				
				while (first <= last) {
					i = (first + last) / 2;
					
					var cur:Node = this._nodes.getItemAt(i) as Node;
					
					if (cur.nodeName == name) {
						return i;
					} else {
						first = i + 1;
					}
				}
				
				if (first > i) {
					i = first;
				}
			}
			
			return -1 - i;
		}
		
		
		/**
		 * Locates a node from the <code>HashMap</code> from the specified start point by <code>namespaceURI</code> and <code>localName</code>.
		 *
		 * @param namespaceURI The namespace URI of the node to retrieve.
		 * @param localName The local name of the node to retrieve.
		 * @param start 0-based index to start the search from.
		 * 
		 * @return <code>INode</code> instance of the matched node.
		 */
		protected function locateNamedNodeNS(namespaceURI:String, name:String, start:int):int {
			var i:int = 0;
			
			if (this._nodes != null) {
				var first:int = start;
				var last:int = this.length - 1;
				
				while (first <= last) {
					i = (first + last) / 2;
					
					var cur:Node = this._nodes[i] as Node;
					
					if (cur.nodeName == name && cur.namespaceURI == namespaceURI) {
						return i;
					} else {
						first = i + 1;
					}
				}
				
				if (first > i) {
					i = first;
				}
			}
			
			return -1 - i;
		}
	}
}