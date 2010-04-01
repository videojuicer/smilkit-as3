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
		
		public function ChildNode(owner:IDocument)
		{
			super(owner);
		}
		
		public override function get parentNode():INode
		{
			return this._ownerDocument;
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