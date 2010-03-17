package org.smilkit.w3c.dom
{
	

	public interface IDocument extends INode
	{
		function get doctype():IDocumentType;
		function get implementation():IDOMImplementation;
		function get documentElement():IElement;
		
		function createElement(tagName:String):IElement;
		function createDocumentFragment():IDocumentFragment;
		function createTextNode(data:String):IText;
		function createComment(data:String):IComment;
		function createCDATASection(data:String):ICDATASection;
		function createProcessingInstruction(target:String, data:String):IProcessingInstruction;
		function createAttribute(name:String):IAttr;
		function createEntityReference(tagname:String):IEntityReference;
		
		function getElementsByTagName(tagname:String):INodeList;
		function importNode(importedNode:INode, deep:Boolean):INode;
		
		function createElementNS(namespaceURI:String, qualifiedName:String):IElement;
		function createAttributeNS(namespaceURI:String, qualifiedName:String):IAttr;
		
		function getElementsByTagNameNS(namespaceURI:String, localName:String):INodeList;
		
		function getElementById(elementId:String):IElement;
	}
}