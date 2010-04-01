package org.smilkit.dom
{
	import org.smilkit.w3c.dom.DOMException;
	import org.smilkit.w3c.dom.INode;
	
	public class AttributeMap extends NamedNodeMap
	{
		public function AttributeMap(ownerNode:INode)
		{
			super(ownerNode);
		}
		
		/**
		 * NON-DOM: Removes the specified <code>INode</code> instance from the list of attributes,
		 * uses object-object comparison rather than looking for the named item.
		 * 
		 * @param item The <code>INode</code> instance to remove.
		 * 
		 * @return Removed <code>INode</code>.
		 */
		internal function removeItem(item:INode):INode
		{
			var index:int = -1;
			
			for (var i:int = 0; i < this._nodes.length; i++)
			{
				if (this._nodes.getItemAt(i) == item) {
					index = i;
					break;
				}
			}
			
			if (index < 0)
			{
				throw new DOMException(DOMException.NOT_FOUND_ERR, DOMMessageFormatter.formatMessage(DOMMessageFormatter.DOM_DOMAIN, "NOT_FOUND_ERR"));
			}
			
			return (this._nodes.removeItemAt(i) as INode);
		}
		
		/**
		 * NON-DOM: Removes the specified <code>INode</code> instance from the list of attributes,
		 * uses object-object comparison rather than looking for the named item.
		 * 
		 * @param item The <code>INode</code> instance to remove.
		 * 
		 * @return Removed <code>INode</code>.
		 */
		internal function removeItemNS(item:INode):INode
		{
			var index:int = -1;
			
			for (var i:int = 0; i < this._nodes.length; i++)
			{
				if (this._nodes.getItemAt(i) == item) {
					index = i;
					break;
				}
			}
			
			if (index < 0)
			{
				throw new DOMException(DOMException.NOT_FOUND_ERR, DOMMessageFormatter.formatMessage(DOMMessageFormatter.DOM_DOMAIN, "NOT_FOUND_ERR"));
			}
			
			return (this._nodes.removeItemAt(i) as INode);
		}
	}
}