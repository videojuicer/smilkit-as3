package org.smilkit.dom
{
	import org.utilkit.collection.List;
	import org.smilkit.w3c.dom.IElement;
	import org.smilkit.w3c.dom.INode;
	import org.smilkit.w3c.dom.INodeList;
	
	/**
	 * DeepNodeList represents a collection of Nodes for the <code>getElementsByTagName()</code>
	 * method. The class implements W3C DOM's INodeList for cability behaviour.
	 *
	 * This object is always live, it will always reflect the current state  of the document tree
	 * it belongs to. The <code>INodeLists</code> obtained before and after an insertation or deletion
	 * would be the same, as the <code>INodeList</code> will change as the DOM is altered.
	 * 
	 * @see org.smilkit.w3c.dom.INodeList
	 */
	public class DeepNodeList implements INodeList
	{
		protected var _rootNode:INode;
		protected var _tagName:String; // tag name or "*" to select all tags
		protected var _nodes:List;
		
		public function DeepNodeList(rootNode:INode, tagName:String)
		{
			this._rootNode = rootNode;
			this._tagName = tagName;
			
			this._nodes = new List();
		}
		
		/**
		 * Returns the length of the node list
		 */
		public function get length():int
		{
			// preload list of nodes
			this.item(int.MAX_VALUE);
			
			return this._nodes.length;
		}
		
		/**
		 * Gets the <code>INode</code> at the specified index.
		 * 
		 * @param index The specified index of the <code>INode</code> to return. 
		 * 
		 * @return The <code>INode</code> instance from the specified index.
		 */
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
		
		/**
		 * Tree-walker, runs through the children nodes where needed
		 * via there <code>parentNode</code>. Only <code>Element</code>
		 * nodes are matched as this functionality is for <code>getElementsByTagName()</code>.
		 *
		 * @param current The <code>INode</code> to start finding the next from.
		 * 
		 * @return The next matching <code>INode</code> after the specified node.
		 */
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