package org.smilkit.w3c.dom
{
	public interface IEntity extends INode
	{
		function get publicId():String;
		function get systemId():String;
		function get notationName():String;
	}
}