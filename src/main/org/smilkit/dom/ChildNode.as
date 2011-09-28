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
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.INode;
	
	/**
	 * The <code>ChildNode</code> implementation adds support for a <code>Node</code>
	 * being a child by having reference to its previous and next siblings and parent.
	 * 
	 * @see org.smilkit.dom.Node
	 * @see org.smilkit.dom.ParentNode
	 */
	public class ChildNode extends Node
	{
		protected var _previousSibling:ChildNode;
		protected var _nextSibling:ChildNode;
		protected var _parentNode:INode = null;
		protected var _orphaned:Boolean = true;
		
		public function ChildNode(owner:IDocument)
		{
			super(owner);
		}
		
		public function get orphaned():Boolean
		{
			return this._orphaned;
		}
		
		public override function get parentNode():INode
		{
			if (this._ownerDocument == this)
			{
				return null;
			}
			
			return this._parentNode;
		}
		
		/**
		 * NON-DOM
		 */
		public function set parentNode(value:INode):void
		{
			this._parentNode = value;
		}
		
		public override function get nextSibling():INode
		{
			return this._nextSibling;
		}
		
		public override function get previousSibling():INode
		{
			return this._previousSibling;
		}
		
		public function set nextSibling(node:INode):void
		{
			this._nextSibling = (node as ChildNode);
		}
		
		public function set previousSibling(node:INode):void
		{
			this._previousSibling = (node as ChildNode);
		}
		
		/**
		 * Returns a duplicate of the current node instance. The returned 
		 * <code>INode</code> will be a complete new object instance.
		 * 
		 * @param deep Specifies whether to copy all the children. This is ignored as
		 * we don't deal with children in this class.
		 * 
		 * @return New <code>INode</code> copy of the current object instance.
		 */
		public override function cloneNode(deep:Boolean):INode
		{
			var newNode:ChildNode = (super.cloneNode(deep) as ChildNode);
			
			newNode.previousSibling = null;
			newNode.nextSibling = null;
			
			return newNode;
		}
	}
}