package org.smilkit.w3c.dom
{
	public interface INotation extends INode
	{
		function get publicId():String;
		function get systemId():String;
	}
}