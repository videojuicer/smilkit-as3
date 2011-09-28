/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version 1.1
 * (the "License"); you may not use this file except in compliance with the
 * License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 *
 * The Original Code is the SMILKit library.
 *
 * The Initial Developer of the Original Code is
 * Videojuicer Ltd. (UK Registered Company Number: 05816253).
 * Portions created by the Initial Developer are Copyright (C) 2010
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 * 	Dan Glegg
 * 	Adam Livesley
 *
 * ***** END LICENSE BLOCK ***** */
package org.smilkit.dom
{
	import org.smilkit.w3c.dom.INode;
	
	public class AttributeMap extends NamedNodeMap
	{
		public function AttributeMap(ownerNode:INode)
		{
			super(ownerNode);
		}
		
		public override function setNamedItem(arg:INode):INode
		{
			var previous:INode = this.getNamedItem(arg.nodeName);
			var attr:Attr = (arg as Attr);
			
			if (attr.ownerElement != null)
			{
				if (attr.ownerElement != this.ownerNode())
				{
					throw new DOMException(DOMException.WRONG_DOCUMENT_ERR, DOMMessageFormatter.formatMessage(DOMMessageFormatter.DOM_DOMAIN, "WRONG_DOCUMENT_ERR"));
				}
			}
			
			var node:INode = super.setNamedItem(arg);
			
			attr.ownerNode = this.ownerNode();
			
			(this._ownerNode.ownerDocument as Document).setAttributeNode(arg, previous);
			
			return previous;
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
			var document:Document = (this._ownerNode.ownerDocument as Document);
			var attr:Attr = (item as Attr); 
			
			if (attr.isAttributeNode)
			{
				document.removeIdentifier(attr.value);
				attr.isAttributeNode = false;
			}
			
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
			
			var node:INode = (this._nodes.removeItemAt(i) as INode);
			
			
			document.removedAttributeNode(node, this._ownerNode, attr.name);
			
			return node;
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