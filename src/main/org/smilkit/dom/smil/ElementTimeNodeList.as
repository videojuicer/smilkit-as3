package org.smilkit.dom.smil
{
	import org.smilkit.w3c.dom.INode;
	import org.smilkit.w3c.dom.INodeList;
	import org.smilkit.w3c.dom.smil.IElementTime;
	import org.smilkit.w3c.dom.smil.IElementTimeContainer;
	import org.smilkit.w3c.dom.smil.ISMILElement;
	import org.utilkit.collection.List;
	
	public class ElementTimeNodeList implements INodeList
	{
		protected var _rootNode:INode;
		protected var _nodes:List;
		
		public function ElementTimeNodeList(rootNode:INode)
		{
			this._rootNode = rootNode;
			
			this._nodes = new List();
		}
		
		public function get length():int
		{
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
					current = this._nodes.getItemAt(this._nodes.length - 1) as INode;
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
				if (current.hasChildNodes())
				{
					current = current.firstChild;
				}
				else if (current != this._rootNode && null != (next = current.nextSibling))
				{
					current = next;
				}
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
				
				if (current != this._rootNode && current != null && current is IElementTimeContainer)
				{
					return current;
				}
			}
			
			return null;
		}
	}
}