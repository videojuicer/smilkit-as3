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
package org.smilkit.dom.smil
{
	import org.smilkit.w3c.dom.INode;
	import org.smilkit.w3c.dom.INodeList;
	import org.smilkit.w3c.dom.smil.IElementTimeContainer;
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