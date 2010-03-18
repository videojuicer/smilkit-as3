package org.smilkit.dom
{
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.IDocumentType;
	import org.smilkit.w3c.dom.INamedNodeMap;
	
	public class DocumentType extends ParentNode implements IDocumentType
	{
		protected var _qualifiedName:String;
		protected var _publicId:String;
		protected var _systemId:String;
		
		protected var _internalSubset:String;
		
		protected var _entities:NamedNodeMap;
		protected var _notations:NamedNodeMap;
		
		public function DocumentType(owner:IDocument, qualifiedName:String, publicId:String = null, systemId:String = null)
		{
			super(owner);
			
			this._qualifiedName = qualifiedName;
			this._publicId = publicId;
			this._systemId = systemId;
			
			this._entities = new NamedNodeMap(this);
			this._notations = new NamedNodeMap(this);
		}
		
		public function get name():String
		{
			return this._qualifiedName;
		}
		
		public override function get nodeType():int
		{
			return Node.DOCUMENT_TYPE_NODE;
		}
		
		public function get entities():INamedNodeMap
		{
			return this._entities;
		}
		
		public function get notations():INamedNodeMap
		{
			return this._notations;
		}
		
		public function get publicId():String
		{
			return this._publicId;
		}
		
		public function get systemId():String
		{
			return this._systemId;
		}
		
		public function get internalSubset():String
		{
			return this._internalSubset;
		}
	}
}