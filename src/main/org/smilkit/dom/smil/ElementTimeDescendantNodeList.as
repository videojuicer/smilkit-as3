package org.smilkit.dom.smil
{
	import org.smilkit.w3c.dom.INode;
	import org.smilkit.w3c.dom.smil.IElementTimeContainer;
	
	public class ElementTimeDescendantNodeList extends ElementTimeNodeList
	{
		/**
		 * Determines whether the loop should keep walking deeper into the tree, we set
		 * this to false when we find the first TimeContainer so that we only find the first
		 * set of TimeContainers that exist in the same scope.
		 */
		protected var _walkParent:INode = null;
		
		public function ElementTimeDescendantNodeList(rootNode:INode)
		{
			super(rootNode);
		}
		
		protected override function nextMatchingAfter(current:INode):INode
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
				
				var timeContainer:ElementTimeContainer = (current as ElementTimeContainer);
				
				if (current != this._rootNode && current != null && timeContainer != null && (this._walkParent == null || this._walkParent == timeContainer.parentTimeContainer))
				{
					this._walkParent = timeContainer.parentTimeContainer;
					
					if (this._walkParent == null || this._walkParent == current)
					{
						this._walkParent = current.parentNode;
					}
					
					return current;
				}
			}
			
			return null;
		}
	}
}