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
	
	public class CoreDocument extends ParentNode implements IDocument
	{
		protected var _documentType:IDocumentType;
		protected var _documentElement:IElement;
		
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
			throw new IllegalOperationError("Method Not Implemented Yet!");
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
			throw new IllegalOperationError("Method Not Implemented Yet!");
		}
		
		public function createEntityReference(tagname:String):IEntityReference
		{
			throw new IllegalOperationError("Method Not Implemented Yet!");
		}
		
		public function getElementsByTagName(tagname:String):INodeList
		{
			throw new IllegalOperationError("Method Not Implemented Yet!");
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
			throw new IllegalOperationError("Method Not Implemented Yet!");
		}
	}
}