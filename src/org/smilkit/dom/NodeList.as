package org.smilkit.dom
{
	import org.smilkit.w3c.dom.INode;
	import org.smilkit.w3c.dom.INodeList;
	
	public class NodeList implements INodeList
	{
		public function NodeList()
		{
		}
		
		public function get length():int
		{
			return 0;
		}
		
		public function item(index:int):INode
		{
			return null;
		}
	}
}