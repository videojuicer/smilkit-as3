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