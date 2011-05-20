package org.smilkit.dom
{
	import flash.errors.IllegalOperationError;
	
	import org.smilkit.w3c.dom.DOMException;
	import org.smilkit.w3c.dom.IAttr;
	import org.smilkit.w3c.dom.ICDATASection;
	import org.smilkit.w3c.dom.IComment;
	import org.smilkit.w3c.dom.IDOMImplementation;
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.IDocumentFragment;
	import org.smilkit.w3c.dom.IDocumentType;
	import org.smilkit.w3c.dom.IElement;
	import org.smilkit.w3c.dom.IEntityReference;
	import org.smilkit.w3c.dom.INode;
	import org.smilkit.w3c.dom.INodeList;
	import org.smilkit.w3c.dom.IProcessingInstruction;
	import org.smilkit.w3c.dom.IText;
	import org.smilkit.w3c.dom.events.IEvent;
	import org.utilkit.collection.Hashtable;
	
	public class CoreDocument extends ParentNode implements IDocument
	{
		protected var _documentType:IDocumentType;
		protected var _documentElement:IElement;
		protected var _identifiers:Hashtable;
		
		public function CoreDocument(documentType:IDocumentType)
		{
			super(this);
			
			if (documentType != null)
			{
				if (!documentType is IDocumentType)
				{
					throw new DOMException(DOMException.WRONG_DOCUMENT_ERR, DOMMessageFormatter.formatMessage(DOMMessageFormatter.DOM_DOMAIN, "WRONG_DOCUMENT_ERR"));
				}
				
				this._documentType = documentType;
			}
		}
		
		/**
		 * DOM Level 2 Specification says this should return null for
		 * <code>Documents</code>.
		 */
		public override final function get ownerDocument():IDocument
		{
			return null;
		}
		
		public override function get orphaned():Boolean
		{
			return false;
		}
		
		public override function get nodeType():int
		{
			return Node.DOCUMENT_NODE;
		}
		
		public override function get nodeName():String
		{
			return "#document";
		}
		
		public function get doctype():IDocumentType
		{
			return this._documentType;
		}
		
		public function get implementation():IDOMImplementation
		{
			return null;
		}
		
		public function get documentElement():IElement
		{
			return this._documentElement;
		}
		
		/**
		 * NON-DOM: Creates a <code>DocumentType</code> instance from the specified arguements.
		 * 
		 * @param qualifiedName Qualified name of the document type.
		 * @param publicId Public ID of the document type.
		 * @param systemId System ID of the document type.
		 * 
		 * @return Returns the created <code>IDocumentType</code> instance.
		 */
		public function createDocumentType(qualifiedName:String, publicId:String, systemId:String):IDocumentType
		{
			return new DocumentType(this, qualifiedName, publicId, systemId);
		}
		
		public function createElement(tagName:String):IElement
		{
			return new Element(this, tagName);
		}
		
		public function createDocumentFragment():IDocumentFragment
		{
			throw new IllegalOperationError("Method Not Implemented Yet!");
		}
		
		public function createTextNode(data:String):IText
		{
			return new Text(this, data);
		}
		
		public function createComment(data:String):IComment
		{
			throw new IllegalOperationError("Method Not Implemented Yet!");
		}
		
		public function createCDATASection(data:String):ICDATASection
		{
			throw new IllegalOperationError("Method Not Implemented Yet!");
		}
		
		public function createProcessingInstruction(target:String, data:String):IProcessingInstruction
		{
			throw new IllegalOperationError("Method Not Implemented Yet!");
		}
		
		public function createAttribute(name:String):IAttr
		{
			return new Attr(this, name);
		}
		
		public function createEntityReference(tagname:String):IEntityReference
		{
			throw new IllegalOperationError("Method Not Implemented Yet!");
		}
		
		/**
		 * Queries the document for a live <code>INodeList</code> of all the matching
		 * descendents.
		 * 
		 * @param tagname The tag name of the <code>INode</code> to collect. "*" can be
		 * used as a wildcard token, matching all elements in the document.
		 * 
		 * @return Live instance of <code>DeepNodeList</code>.
		 * 
		 * @see DeepNodeList
		 */
		public function getElementsByTagName(tagName:String):INodeList
		{
			return new DeepNodeList(this, tagName);
		}
		
		public function importNode(importedNode:INode, deep:Boolean):INode
		{
			throw new IllegalOperationError("Method Not Implemented Yet!");
		}
		
		public function createElementNS(namespaceURI:String, qualifiedName:String):IElement
		{
			throw new IllegalOperationError("Method Not Implemented Yet!");
		}
		
		public function createAttributeNS(namespaceURI:String, qualifiedName:String):IAttr
		{
			throw new IllegalOperationError("Method Not Implemented Yet!");
		}
		
		public function getElementsByTagNameNS(namespaceURI:String, localName:String):INodeList
		{
			throw new IllegalOperationError("Method Not Implemented Yet!");
		}
		
		public function getElementById(elementId:String):IElement
		{
			return this.getIdentifier(elementId);
		}
		
		internal function addNodeEventListener(node:INode, type:String, listener:Function, useCapture:Boolean):void
		{
			
		}
		
		internal function removeNodeEventListener(node:INode, type:String, listener:Function, useCapture:Boolean):void
		{
			
		}
		
		internal function dispatchNodeEvent(node:INode, event:IEvent):Boolean
		{
			return false;
		}
		
		public function getIdentifier(id:String):IElement
		{
			if (this._identifiers == null)
			{
				return null;
			}
			
			var i:int = this._identifiers.getNamedIndex(id);
			
			var element:IElement = this._identifiers.getItem(id) as IElement;
			
			if (element != null)
			{
				var parent:INode = element.parentNode;
				
				while (parent != null)
				{
					if (parent == this)
					{
						return element;
					}
					
					parent = parent.parentNode;
				}
			}
			
			return element;
		}
		
		public function removeIdentifier(id:String):void
		{
			if (this._identifiers == null)
			{
				return;
			}
			
			this._identifiers.removeItem(id);
		}
		
		public function addIdentifier(id:String, element:IElement):void
		{
			if (this._identifiers == null)
			{
				this._identifiers = new Hashtable();
			}
			
			this._identifiers.setItem(id, element);
		}
		
		public override function ancestorChanged(newAncestor:ParentNode = null):void
		{
			return;
		}
	}
}