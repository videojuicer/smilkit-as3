package org.smilkit.dom
{
	import org.smilkit.w3c.dom.DOMException;
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.INode;
	import org.smilkit.w3c.dom.INodeList;
	
	public class ParentNode extends ChildNode
	{
		protected var _firstChild:INode = null;
		protected var _childNodeCount:int = -1;
		
		protected var _orphaned:Boolean = true;
		
		public function ParentNode(owner:IDocument)
		{
			super(owner);
		}
		
		public override function get ownerDocument():IDocument
		{
			return this._ownerDocument;
		}
		
		public override function set parentNode(value:INode):void
		{
			super.parentNode = value;
			
			this.ancestorChanged((value as ParentNode));
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
			var firstChild:ChildNode = (this.firstChild as ChildNode);
			
			if (firstChild != null)
			{
				return firstChild.previousSibling;	
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
			if (newChild.ownerDocument != (this as ParentNode)._ownerDocument && newChild != (this as ParentNode)._ownerDocument)
			{
				throw new DOMException(DOMException.WRONG_DOCUMENT_ERR, DOMMessageFormatter.formatMessage(DOMMessageFormatter.DOM_DOMAIN, "WRONG_DOCUMENT_ERR"));
			}
			
			if (refChild != null && refChild.parentNode != this)
			{
				throw new DOMException(DOMException.NOT_FOUND_ERR, DOMMessageFormatter.formatMessage(DOMMessageFormatter.DOM_DOMAIN, "NOT_FOUND_ERR"));
			}

			if (newChild == refChild)
			{
				refChild = refChild.nextSibling;
				this.removeChild(newChild);
				this.insertBefore(newChild, refChild);
				
				return newChild;
			}
			
			var safe:Boolean = true;
			//var c:INode = this;
			
			//while (c != null)
			//{
			//	safe = newChild != c;
				
			//	c = c.parentNode;
			//}
			
			//for (var a:INode = this; safe && a != null; a = a.parentNode)
			//{
			//	safe = newChild != a;
			//}
			
			if (!safe)
			{
				throw new DOMException(DOMException.HIERARCHY_REQUEST_ERR, DOMMessageFormatter.formatMessage(DOMMessageFormatter.DOM_DOMAIN, "HIERARCHY_REQUEST_ERR"));
			}
			
			(this._ownerDocument as Document).insertingNode(this, false);
			
			var newInternal:ChildNode = (newChild as ChildNode);
			var refInternal:ChildNode = (refChild as ChildNode);
			
			newInternal.parentNode = this;

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
			
			this.changed();
			
			// invalidate cache
			this._childNodeCount = -1;
			
			(this._ownerDocument as Document).insertedNode(this, newInternal, false);
			
			// sent out changed event
			return newChild;
		}
		
		public override function removeChild(oldChild:INode):INode
		{
			if (oldChild != null && oldChild.parentNode != this)
			{
				throw new DOMException(DOMException.NOT_FOUND_ERR, DOMMessageFormatter.formatMessage(DOMMessageFormatter.DOM_DOMAIN, "NOT_FOUND_ERR"));
			}
			
			(this._ownerDocument as Document).removingNode(this, oldChild, false);
			
			if (oldChild == this.firstChild)
			{
				this._firstChild = oldChild.nextSibling;
				
				if (this.firstChild != null)
				{
					(this.firstChild as ChildNode).previousSibling = (oldChild.previousSibling as ChildNode);
				}
			}
			else
			{
				var prevChild:ChildNode = (oldChild.previousSibling as ChildNode);
				var nextChild:ChildNode = (oldChild.nextSibling as ChildNode);
				
				prevChild.nextSibling = nextChild;
				
				if (nextChild == null)
				{
					(this.firstChild as ChildNode).previousSibling = prevChild;
				}
				else
				{
					(nextChild as ChildNode).previousSibling = prevChild;
				}
			}
			
			(oldChild as ParentNode)._ownerDocument = null;
			(oldChild as ChildNode).nextSibling = null;
			(oldChild as ChildNode).previousSibling = null;
			
			// invalidate cache
			this._childNodeCount = -1;
			
			if (oldChild is Element)
			{
				var oldElement:Element = (oldChild as Element);
				
				if (oldElement.id != "" && oldElement.id != null)
				{
					(this._ownerDocument as Document).removeIdentifier(oldElement.id);
				}
			}
			
			this.changed();
			
			(this._ownerDocument as Document).removedNode(this, false);
			
			return oldChild;
		}
		
		public override function replaceChild(newChild:INode, oldChild:INode):INode
		{
			(this._ownerDocument as Document).replacingNode(this);
			
			this.insertBefore(newChild, oldChild);
			
			if (newChild != oldChild)
			{
				this.removeChild(oldChild);
			}
			
			(this._ownerDocument as Document).replacedNode(this);
			
			return oldChild;
		}
		
		private function invalidateNodeCache():void
		{
			if (this._childNodeCount == -1)
			{
				var node:ChildNode = (this.firstChild as ChildNode);
				this._childNodeCount = 0;
				
				for (; node != null; node = (node.nextSibling as ChildNode))
				{
					this._childNodeCount++;
				}
			}
		}
		
		public override function get length():int
		{
			this.invalidateNodeCache();
			
			return this._childNodeCount;
		}
		
		public override function item(index:int):INode
		{
			if (this.firstChild == this.lastChild)
			{
				return (index == 0 ? this.firstChild : null);
			}
			
			if (index < 0)
			{
				return null;
			}
			
			var child:ChildNode = (this.firstChild as ChildNode);
			
			for (var i:int = 0; i < index && child != null; i++)
			{
				child = (child.nextSibling as ChildNode);
			}
			
			return child;
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
		
		public function ancestorChanged(newAncestor:ParentNode = null):void
		{
			if (newAncestor != null)
			{
				
			}
			
			// update the children
			var child:ParentNode = (this.firstChild as ParentNode);
			
			if (child != null)
			{
				for (var i:int = 0; i < this.childNodes.length; i++)
				{
					child = (this.childNodes.item(i) as ParentNode);
					
					child.ancestorChanged(newAncestor);
				}
			}
		}
	}
}