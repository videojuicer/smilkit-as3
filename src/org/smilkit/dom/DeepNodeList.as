package org.smilkit.dom
{
	import org.smilkit.util.HashMap;
	import org.smilkit.w3c.dom.IElement;
	import org.smilkit.w3c.dom.INode;
	import org.smilkit.w3c.dom.INodeList;
	
	public class DeepNodeList implements INodeList
	{
		protected var _rootNode:INode;
		protected var _tagName:String; // tag name or "*" to select all tags
		protected var _nodes:HashMap;
		
		public function DeepNodeList(rootNode:INode, tagName:String)
		{
			this._rootNode = rootNode;
			this._tagName = tagName;
			
			this._nodes = new HashMap();
		}
		
		public function get length():int
		{
			// preload list of nodes
			this.item(int.MAX_VALUE);
			
			return this._nodes.length;
		}
		
		public function item(index:int):INode
		{
			var current:INode = null;
			
			if (index < this._nodes.length)
			{
				current = this._nodes.getItemAt(index) as INode;
			}
			else
			{
				if (this._nodes.length == 0)
				{
					current = this._rootNode;
				}
				else
				{
					current = this._nodes.getItemAt(this._nodes.length - 1) as INode;
				}
				
				while (current != null && index >= this._nodes.length)
				{
					current = this.nextMatchingAfter(current);
					
					if (current != null)
					{
						this._nodes.addItem(current);
					}
				}
			}
			
			return current;
		}
		
		protected function nextMatchingAfter(current:INode):INode
		{
			var next:INode = null;
			
			while (current != null)
			{
				// look down the first child
				if (current.hasChildNodes())
				{
					current = current.firstChild;
				}
				// look right to the sibling
				else if (current != this._rootNode && null != (next = current.nextSibling))
				{
					current = next;
				}
				// look up and right
				else
				{
					next = null;
					
					for (; current != this._rootNode; current = current.parentNode)
					{
						next = current.nextSibling;
						
						if (next != null)
						{
							break;
						}
					}
					
					current = next;
				}
				
				// have we found an Element with the right tagName?
				if (current != this._rootNode && current != null && current.nodeType == Node.ELEMENT_NODE)
				{
					if (this._tagName == "*" || (current as IElement).tagName == this._tagName)
					{
						return current;
					}
				}
			}
			
			return null;
		}
	}
}