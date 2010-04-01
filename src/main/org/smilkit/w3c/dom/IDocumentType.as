package org.smilkit.w3c.dom
{
	public interface IDocumentType extends INode
	{
		function get name():String;
		function get entities():INamedNodeMap;
		function get notations():INamedNodeMap;
		function get publicId():String;
		function get systemId():String;
		function get internalSubset():String;
	}
}