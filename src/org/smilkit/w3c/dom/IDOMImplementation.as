package org.smilkit.w3c.dom
{
	public interface IDOMImplementation
	{
		function hasFeature(feature:String, version:String):Boolean;
		function createDocumentType(qualifiedName:String, publicId:String, systemId:String):IDocumentType;
		function createDocument(namespaceURI:String, qualifiedName:String, doctype:IDocumentType):IDocument;
	}
}