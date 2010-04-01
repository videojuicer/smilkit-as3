package org.smilkit.w3c.dom
{
	public interface INodeList
	{
		function get length():int;
		
		function item(index:int):INode;
	}
}