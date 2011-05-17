package org.smilkit.view
{
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.render.RenderTree;
	import org.smilkit.load.LoadScheduler;

	public dynamic class ViewportObjectPool
	{
		protected var _viewport:Viewport;
		
		/**
		 * Holds the DOM - data Representation of the loaded SMIL XML 
		 */		
		protected var _document:SMILDocument;
		
		/**
		 *  An instance of RenderTree responsible for checking the viewports play position and for controlling the display 
		 */	
		protected var _renderTree:RenderTree;
		
		/* 
		 * An instance of LoadScheduler responsible for determining current load priorities and performing opportunistic
		 * loading where possible.
		*/
		protected var _loadScheduler:LoadScheduler;
		
		public function ViewportObjectPool(viewport:Viewport, document:SMILDocument)
		{
			this._viewport = viewport;
			this._document = document;
			
			this.reset();
		}
		
		public function get viewport():Viewport
		{
			return this._viewport;
		}

		public function get document():SMILDocument
		{
			return this._document;
		}
		
		public function get renderTree():RenderTree
		{
			return this._renderTree;
		}
		
		public function get loadScheduler():LoadScheduler
		{
			return this._loadScheduler;
		}
		
		public function reset():void
		{
			// link the object pool to the document
			this._document.viewportObjectPool = this;

			// make the first render tree!
			this._renderTree = new RenderTree(this);
			
			// schedule those loads
			this._loadScheduler = new LoadScheduler(this);
			
			// create render tree to drawingboard
			// drawingboard is always around, and renderTree is constantly destroyed
			// and recreated, so we have to make the link.
			this.viewport.drawingBoard.renderTree = this.renderTree;
		}
	}
}