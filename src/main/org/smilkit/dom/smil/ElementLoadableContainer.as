package org.smilkit.dom.smil
{
	import org.smilkit.dom.Node;
	import org.smilkit.w3c.dom.INode;
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.dom.smil.SMILElement;
	import org.smilkit.dom.smil.SMILDocumentLoadables;
	import org.smilkit.dom.smil.FileSize;
	
	public class ElementLoadableContainer extends SMILElement
	{
		// The "intrinsic" properties are those specifically belonging to this element,
		// if this element is loadable.
		// The intrinsic properties are those that will be written to by a loading handler.
		protected var _intrinsicBytesLoaded:int = 0;
		protected var _intrinsicBytesTotal:int = 0;
		// These are the totals for any child ElementLoadableContainer instances
		protected var _childrenBytesLoaded:int = 0;
		protected var _childrenBytesTotal:int = 0;
		
		public function ElementLoadableContainer(owner:IDocument, name:String)
		{
			super(owner, name);
		}
		
		public function get bytesLoaded():int
		{
			if(this._intrinsicBytesLoaded == FileSize.UNRESOLVED || this._childrenBytesLoaded == FileSize.UNRESOLVED)
			{
				return FileSize.UNRESOLVED;
			}
			else
			{
				return this._intrinsicBytesLoaded + this._childrenBytesLoaded;
			}
		}
		
		public function get bytesTotal():int
		{
			if(this._intrinsicBytesTotal == FileSize.UNRESOLVED || this._childrenBytesTotal == FileSize.UNRESOLVED)
			{
				return FileSize.UNRESOLVED;
			}
			else
			{
				return this._intrinsicBytesTotal + this._childrenBytesTotal;
			}
		}
		
		public function set intrinsicBytesLoaded(l:int):void
		{
			if(this._intrinsicBytesLoaded != l)
			{
				this._intrinsicBytesLoaded = l;
				this.updateParentLoadableContainer();
			}
		}
		
		public function set intrinsicBytesTotal(t:int):void
		{
			if(this._intrinsicBytesTotal != t)
			{
				this._intrinsicBytesTotal = t;
				this.updateParentLoadableContainer();
			}
		}
		
		public function set childrenBytesLoaded(l:int):void
		{
			if(this._childrenBytesLoaded != l)
			{
				this._childrenBytesLoaded = l;
				this.updateParentLoadableContainer();
			}
		}
		
		public function set childrenBytesTotal(t:int):void
		{
			if(this._childrenBytesTotal != t)
			{
				this._childrenBytesTotal = t;
				this.updateParentLoadableContainer();
			}
		}
		
		public function updateParentLoadableContainer():void
		{
			var p:ElementLoadableContainer = this.parentLoadableContainer;
			if(p!=null)
			{
				// Update ancestor element
				p.resolveChildLoadableSizes();
			}
			else {
				// Update document
				if(this._ownerDocument != null)
				{
					(this._ownerDocument as SMILDocument).loadables.resolveChildLoadableSizes();
				}
			}
		}
		
		public function resolveChildLoadableSizes(e:INode = null):Array
		{
			// Loadable containers are not traversed, all other elements ARE traversed (e.g. links)
			// Any contact with UNRESOLVED will break the loop and return unresolved
			var container:INode = (e == null)? this : e;
			var bl:int = 0; // Accumulator for bytes loaded
			var bt:int = 0; // Accumulator for bytes total
			var blResolved:Boolean = true; // Resolution flag for bytes loaded
			var btResolved:Boolean = true; // Resolution flag for bytes total
			for(var i:uint=0; i < container.childNodes.length; i++)
			{
				var child:INode = container.childNodes.item(i);
				var childBl:int = 0;
				var childBt:int = 0;
				if(child is ElementLoadableContainer)
				{
					childBl = (child as ElementLoadableContainer).bytesLoaded;
					childBt = (child as ElementLoadableContainer).bytesTotal;
				}
				else
				{
					var recursionResult:Array = this.resolveChildLoadableSizes(child);
					childBl = recursionResult[0]; childBt = recursionResult[1];
				}
				// Now work with the returned values from the child to see if we hit unresolved
				if(childBl == FileSize.UNRESOLVED)
				{
					blResolved = false;
					if(!blResolved && !btResolved) break; 
				}
				else
				{
					bl += childBl;
				}
				
				if(childBt == FileSize.UNRESOLVED)
				{
					btResolved = false;
					if(!blResolved && !btResolved) break;
				}
				else
				{
					bt += childBt;
				}
			}
			// Finalise values
			this.childrenBytesLoaded = (blResolved)? bl : FileSize.UNRESOLVED;
			this.childrenBytesTotal = (btResolved)? bt : FileSize.UNRESOLVED;
			return [this.bytesLoaded, this.bytesTotal];
		}
		
		public function get parentLoadableContainer():ElementLoadableContainer
		{
			var parent:INode = this.parentNode;
			while(parent != null && !(parent is ElementLoadableContainer))
			{
				parent = parent.parentNode;
			}
			return parent as ElementLoadableContainer;
		}
	}
}