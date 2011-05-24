package org.smilkit.dom
{
	import org.smilkit.w3c.dom.IAttr;
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.IElement;
	import org.smilkit.w3c.dom.INamedNodeMap;
	import org.smilkit.w3c.dom.INodeList;
	
	public class Element extends ParentNode implements IElement
	{
		protected var _name:String;
		protected var _attributes:AttributeMap;
		
		public function Element(owner:IDocument, name:String)
		{
			super(owner);
			
			this._name = name;
			this._attributes = new AttributeMap(this);
		}
		
		public function get id():String
		{
			if (this.hasAttributeNS("xml", "id"))
			{
				return this.getAttributeNS("xml", "id").toString();
			}
			
			return this.getAttribute("id");//.toString();
		}
		
		public function set id(id:String):void
		{
			if (this.hasAttributeNS("xml", "id"))
			{
				return this.setAttributeNS("xml", "id", id);
			}
			
			this.setAttribute("id", id);
		}
		
		public function get tagName():String
		{
			return this._name;
		}
		
		public override function get nodeType():int
		{
			return Node.ELEMENT_NODE;
		}
		
		public override function get nodeName():String
		{
			return this._name;
		}
		
		public override function get attributes():INamedNodeMap
		{
			return this._attributes;
		}
		
		/**
		 * Queries the element for a live <code>INodeList</code> of all the matching
		 * descendents.
		 * 
		 * @param tagname The tag name of the <code>INode</code> to collect. "*" can be
		 * used as a wildcard token, matching all descendents from this element.
		 * 
		 * @return Live instance of <code>DeepNodeList</code>.
		 * 
		 * @see DeepNodeList
		 */
		public function getElementsByTagName(name:String):INodeList
		{
			return new DeepNodeList(this, name) as INodeList;
		}
		
		public function getElementsByTagNameNS(namespaceURI:String, localName:String):INodeList
		{
			return null;
		}
		
		public function getAttribute(name:String):String
		{
			if (this._attributes == null)
			{
				return null;
			}
			
			var attr:IAttr = (this._attributes.getNamedItem(name) as IAttr);
			return (attr == null) ? null : attr.value;
		}
		
		public function setAttribute(name:String, value:String):void
		{
			var newAttr:IAttr = this.getAttributeNode(name);
			if (newAttr == null)
			{
				newAttr = this.ownerDocument.createAttribute(name);
				
				if (this._attributes == null)
				{
					this._attributes = new AttributeMap(this);
				}
				
				newAttr.value = value;
				
				this._attributes.setNamedItem(newAttr);
			}
			else
			{
				newAttr.value = value;
			}
		}
		
		public function removeAttribute(name:String):void
		{
			if (this._attributes == null)
			{
				return;
			}
			
			this._attributes.removeNamedItem(name);
		}
		
		public function getAttributeNode(name:String):IAttr
		{
			if (this._attributes == null)
			{
				return null;
			}
			
			return (this._attributes.getNamedItem(name) as IAttr);
		}
		
		public function setAttributeNode(newAttr:IAttr):IAttr
		{
			if (newAttr.ownerDocument != this.ownerDocument)
			{
				throw new DOMException(DOMException.WRONG_DOCUMENT_ERR, DOMMessageFormatter.formatMessage(DOMMessageFormatter.DOM_DOMAIN, "WRONG_DOCUMENT_ERR"));
			}
			
			if (this._attributes == null)
			{
				this._attributes = new AttributeMap(this);
			}
			
			return (this._attributes.setNamedItem(newAttr) as IAttr);
		}
		
		public function removeAttributeNode(oldAttr:IAttr):IAttr
		{
			if (this._attributes == null)
			{
				throw new DOMException(DOMException.NOT_FOUND_ERR, DOMMessageFormatter.formatMessage(DOMMessageFormatter.DOM_DOMAIN, "NOT_FOUND_ERR"));
			}
			
			return (this._attributes.removeItem(oldAttr) as IAttr);
		}
		
		public function getAttributeNS(namespaceURI:String, localName:String):Object
		{
			if (this._attributes == null)
			{
				return null;
			}
			
			var attr:IAttr = (this._attributes.getNamedItemNS(namespaceURI, localName) as IAttr);
			return (attr == null) ? null : attr.value;	
		}
		
		/**
		 * Set's the <code>IAttr</code> object value or creates a new one.
		 * Uses <code>namespaceURI</code> and <code>localName</code> to match an existing attribute.
		 * 
		 * @param namespaceURI Namespace URI of the attribute to look for.
		 * @param localName Local name of the attribute to look for.
		 * @param value Data to set on the found attributes value property.
		 * 
		 * @return The found <code>IAttr</code> instance or null if no match could be found.
		 */
		public function setAttributeNS(namespaceURI:String, qualifiedName:String, value:String):void
		{
			var newAttr:IAttr = this.getAttributeNodeNS(namespaceURI, qualifiedName);
			if (newAttr == null)
			{
				newAttr = this.ownerDocument.createAttributeNS(namespaceURI, qualifiedName);
				
				if (this._attributes == null)
				{
					this._attributes = new AttributeMap(this);
				}
				
				newAttr.value = value;
				
				this._attributes.setNamedItemNS(newAttr);
			}
			else
			{
				newAttr.value = value;
			}
		}
		
		/**
		 * Gets the <code>IAttr</code> instance from the <code>name</code>
		 * 
		 * @param name Name of the attribute to look for.
		 * 
		 * @return The found <code>IAttr</code> instance or null if no match could be found.
		 */
		public function removeAttributeNS(namespaceURI:String, localName:String):void
		{
			if (this._attributes == null)
			{
				return;
			}
			
			this._attributes.removeNamedItemNS(namespaceURI, localName);
		}
		
		/**
		 * Gets the <code>IAttr</code> instance from the <code>namespaceURI</code> and <code>localName</code>.
		 * 
		 * @param namespaceURI Namespace URI of the attribute to look for.
		 * @param localName Local name of the attribute to look for.
		 * 
		 * @return The found <code>IAttr</code> instance or null if no match could be found.
		 */
		public function getAttributeNodeNS(namespaceURI:String, localName:String):IAttr
		{
			if (this._attributes == null)
			{
				return null;
			}
			
			return (this._attributes.getNamedItemNS(namespaceURI, localName) as IAttr);
		}
		
		/**
		 * Removes the specified namespaced <code>IAttr</code> by <code>name</code>
		 * 
		 * @param name Name of the attribute to remove.
		 * 
		 * @return The removed <code>IAttr</code> or null if the attribute was not found.
		 */
		public function setAttributeNodeNS(newAttr:IAttr):IAttr
		{
			if (newAttr.ownerDocument != this.ownerDocument)
			{
				throw new DOMException(DOMException.WRONG_DOCUMENT_ERR, DOMMessageFormatter.formatMessage(DOMMessageFormatter.DOM_DOMAIN, "WRONG_DOCUMENT_ERR"));
			}
			
			if (this._attributes == null)
			{
				this._attributes = new AttributeMap(this);
			}
			
			return (this._attributes.setNamedItemNS(newAttr) as IAttr);
		}
		
		/**
		 * Removes the specified namespaced <code>IAttr</code> by <code>namespaceURI</code> and <code>localName</code>.
		 * 
		 * @param namespaceURI Namespace URI of the attribute to remove.
		 * @param localName Local name of the attribute to remove.
		 * 
		 * @return The removed <code>IAttr</code> or null if the attribute was not found.
		 */
		public function removeAttributeNodeNS(oldAttr:IAttr):IAttr
		{
			if (this._attributes == null)
			{
				throw new DOMException(DOMException.NOT_FOUND_ERR, DOMMessageFormatter.formatMessage(DOMMessageFormatter.DOM_DOMAIN, "NOT_FOUND_ERR"));
			}
			
			return (this._attributes.removeItemNS(oldAttr) as IAttr);
		}
		
		/**
		 * Check's whether the specified <code>IAttr</code> exists by <code>name</code>.
		 * 
		 * @param name Name of the attribute to look for.
		 * 
		 * @return True if the attribute exists, false if not.
		 */
		public function hasAttribute(name:String):Boolean
		{
			if (this._attributes == null)
			{
				return false;
			}
			
			return (this._attributes.getNamedItem(name) != null);
		}
		
		/**
		 * Check's whether the specified <code>IAttr</code> exists by <code>namespaceURI</code> and <code>localName</code>.
		 * 
		 * @param namespaceURI Namespace URI of the attribute to look for.
		 * @param localName Local name of the attribute to look for.
		 * 
		 * @return True if the attribute exists, false if not.
		 */
		public function hasAttributeNS(namespaceURI:String, localName:String):Boolean
		{
			if (this._attributes == null)
			{
				return false;
			}
			
			return (this._attributes.getNamedItemNS(namespaceURI, localName) != null);
		}
		
		public override function hasAttributes():Boolean
		{
			if (this._attributes != null)
			{
				if (this._attributes.length > 0)
				{
					return true;
				}
			}
			
			return false;
		}
		
		public function setIdAttribute(value:String):void
		{
			this.setAttribute("id", value);
			
			(this.ownerDocument as Document).addIdentifier(value, this);
		}
	}
}