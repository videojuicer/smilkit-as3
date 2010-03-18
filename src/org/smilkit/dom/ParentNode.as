package org.smilkit.dom
{
	import org.smilkit.w3c.dom.DOMException;
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.INode;
	import org.smilkit.w3c.dom.INodeList;
	
	public class ParentNode extends ChildNode
	{
		protected var _firstChild:INode = null;
		protected var _nodes:Array = null;
		
		public function ParentNode(owner:IDocument)
		{
			super(owner);
		}
		
		public override function get childNodes():INodeList
		{
			return this;
		}
		
		/**
		 * The first child of the current <code>Node</code> or null if empty.
		 */
		public override function get firstChild():INode
		{
			return this._firstChild;
		}
		
		/**
		 * Returns the last child of this <code>Node</code> or null if nothing exists.
		 */
		public override function get lastChild():INode
		{
			if (this.firstChild != null)
			{
				return this.firstChild.previousSibling;	
			}
			
			return null;
		}
		
		/**
		 * Sets the last child, the last child is set as the <code>previousSibling</code>
		 * on the <code>firstChild</code>.
		 */
		public function set lastChild(node:INode):void
		{
			if (this.firstChild != null)
			{
				(this._firstChild as ChildNode).previousSibling = node;
			}
		}
		
		/**
		 * Returns a duplicate of the current node instance. The returned 
		 * <code>INode</code> will be a complete new object instance.
		 * 
		 * @param deep Specifies whether to copy all the children.
		 * 
		 * @return New <code>INode</code> copy of the current object instance.
		 */
		public override function cloneNode(deep:Boolean):INode
		{
			var newNode:ParentNode = super.cloneNode(deep) as ParentNode;
			newNode._ownerDocument = ownerDocument;
			newNode._firstChild = null;
			newNode._nodes = null;
			
			if (deep)
			{
				var child:INode = this._firstChild;
				
				while (child != null)
				{
					newNode.appendChild(child.cloneNode(true));
					child = child.nextSibling;
				}
			}
			
			return newNode;
		}
		
		public override function hasChildNodes():Boolean
		{
			return (this._firstChild != null);
		}
		
		public override function insertBefore(newChild:INode, refChild:INode):INode
		{
			if (newChild.ownerDocument != this.ownerDocument && newChild != this.ownerDocument)
			{
				throw new DOMException(DOMException.WRONG_DOCUMENT_ERR, DOMMessageFormatter.formatMessage(DOMMessageFormatter.DOM_DOMAIN, "WRONG_DOCUMENT_ERR"));
			}
			
			if (refChild != null && refChild.parentNode != this)
			{
				throw new DOMException(DOMException.NOT_FOUND_ERR, DOMMessageFormatter.formatMessage(DOMMessageFormatter.DOM_DOMAIN, "NOT_FOUND_ERR"));
			}
			
			var safe:Boolean = true;
			var c:INode = this;
			
			while (c != null)
			{
				safe = newChild != c;
				
				c = c.parentNode;
			}
			
			if (!safe)
			{
				throw new DOMException(DOMException.HIERARCHY_REQUEST_ERR, DOMMessageFormatter.formatMessage(DOMMessageFormatter.DOM_DOMAIN, "HIERARCHY_REQUEST_ERR"));
			}
			
			if (newChild == refChild)
			{
				refChild = refChild.nextSibling;
				this.removeChild(newChild);
				this.insertBefore(newChild, refChild);
				
				return newChild;
			}
			
			var newInternal:ChildNode = (newChild as ChildNode);
			var refInternal:ChildNode = (refChild as ChildNode);
			
			// first + only child
			if (this.firstChild == null)
			{
				this._firstChild = newChild;
				newInternal.previousSibling = newChild;
			}
			else
			{
				// append
				if (refInternal == null)
				{
					var lastChild:ChildNode = (this.firstChild.previousSibling as ChildNode);
					lastChild.nextSibling = newChild;
					newInternal.previousSibling = this.firstChild.previousSibling;
					(this.firstChild as ChildNode).previousSibling = newChild;
				}
				// insert
				else
				{
					// at the start
					if (refChild == this.firstChild)
					{
						newInternal.nextSibling = this.firstChild;
						newInternal.previousSibling = this.firstChild.previousSibling;
						(this.firstChild as ChildNode).previousSibling = newInternal;
						this._firstChild = newInternal;
					}
					// everywhere else
					else
					{
						var prevChild:ChildNode = (refInternal.previousSibling as ChildNode);
			
						newInternal.nextSibling = refInternal;
						prevChild.nextSibling = newInternal;
						refInternal.previousSibling = newInternal;
						newInternal.previousSibling = prevChild;
					}
				}
			}
			
			// sent out changed event
			return newChild;
		}
		
		public override function replaceChild(newChild:INode, oldChild:INode):INode
		{
			this.insertBefore(newChild, oldChild);
			
			if (newChild != oldChild)
			{
				this.removeChild(oldChild);
			}
			
			// send out replace event
			
			return oldChild;
		}
		
		public override function item(index:int):INode
		{
			if (this.firstChild == this.lastChild)
			{
				return (index== 0 ? this.firstChild : null);
			}
			
			// <TODO>
			
			return null;
		}
		
		public override function normalize():void
		{
			var child:INode = this.firstChild;
			
			while (child != null)
			{
				child.normalize();
				
				child = child.nextSibling;
			}
		}
	}
}