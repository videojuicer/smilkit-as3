package org.smilkit.view
{
	import flash.display.Sprite;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.containers.Canvas;
	
	import org.smilkit.SMILKit;
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.events.ViewportEvent;
	import org.smilkit.load.LoadScheduler;
	import org.smilkit.render.DrawingBoard;
	import org.smilkit.render.RenderTree;
	import org.smilkit.time.Heartbeat;
	import org.smilkit.time.TimingGraph;
	import org.smilkit.w3c.dom.smil.ISMILDocument;

	public class Viewport extends EventDispatcher
	{
		/**
		 *  An instance of ViewportObjectPool responsible for the active documents object pool.
		 */		
		protected var _objectPool:ViewportObjectPool;
		
		/**
		 * An instance of Heartbeat, the class which is responsible for controlling the rate at which the player updates and redraws 
		 */		
		protected var _heartbeat:Heartbeat;
		
		/**
		 * Contains the main canvas Sprite to which all RenderTree elements are drawn and displayed
		 */	
		protected var _drawingBoard:DrawingBoard;
		
		protected var _currentIndex:int = -1;
		protected var _history:Vector.<String>;
		protected var _autoRefresh:Boolean = true;
		
		public function Viewport()
		{
			this._history = new Vector.<String>();
			this._heartbeat = new Heartbeat(Heartbeat.BPS_5);
			this._drawingBoard = new DrawingBoard();
		}
		
		/**
		 * The current offset for the current <code>Document</code>.
		 */
		public function get offset():Number
		{
			return this._heartbeat.offset;
		}
		
		/**
		 * Indicates whether the <code>Viewport</code> is playing or not.
		 */
		public function get playing():Boolean
		{
			return this._heartbeat.running;
		}
		
		/**
		 * Returns the current <code>ViewportObjectPool</code>.
		 * 
		 * @see org.smilkit.view.ViewportObjectPool
		 */
		public function get viewportObjectPool():ViewportObjectPool
		{
			return this._objectPool;
		}
		
		/**
		 * Returns the current active <code>SMILDocument</code>.
		 * 
		 * @see org.smilkit.dom.smil.SMILDocument
		 */
		public function get document():ISMILDocument
		{
			if(!this.viewportObjectPool) return null;
			return this.viewportObjectPool.document;
		}
		
		/**
		 * Returns the current <code>TimingGraph</code> object for the active document.
		 * 
		 * @see org.smilkit.time.TimingGraph
		 */
		public function get timingGraph():TimingGraph
		{
			if(!this.viewportObjectPool) return null;
			return this.viewportObjectPool.timingGraph;
		}
		
		/**
		* Returns the current <code>LoadScheduler</code> object for the active document.
		* @see org.smilkit.load.LoadScheduler
		*/
		public function get loadScheduler():LoadScheduler
		{
			if(!this.viewportObjectPool) return null;
			return this.viewportObjectPool.loadScheduler;
		}
		
		/**
		 * Returns the current <code>RenderTree</code> object for the active document.
		 * 
		 * @see org.smilkit.render.RenderTree
		 */
		public function get renderTree():RenderTree
		{
			if(!this.viewportObjectPool) return null;
			return this.viewportObjectPool.renderTree;
		}
		
		/**
		 * Returns the current <code>Heartbeat</code> object for the active document.
		 * 
		 * @see org.smilkit.time.Heartbeat
		 */
		public function get heartbeat():Heartbeat
		{
			return this._heartbeat;
		}
		
		/**
		 * Returns the current <code>DrawingBoard</code> object for the active document.
		 * 
		 * @see org.smilkit.render.DrawingBoard
		 */
		public function get drawingBoard():DrawingBoard
		{
			return this._drawingBoard;
		}

		public function get history():Vector.<String>
		{
			return this._history;
		}
		
		/**
		 * The current location for the <code>Viewport</code>, a URL pointing to the
		 * active SMIL document. 
		 */
		public function get location():String
		{
			if (this._currentIndex == -1)
			{
				return null;
			}
			
			return this._history[this._currentIndex];
		}
		
		/**
		 * Sets the URL location for the code>Viewport</code> location, will auto load the requested
		 * location unless <code>autoRefresh</code> is set to false.
		 * 
		 * @see org.smilkit.view.Viewport.autoRefresh
		 */
		public function set location(location:String):void
		{
			if (location == this.location)
			{
				throw new IllegalOperationError("Attempting to navigate to the same location.");
			}
			
			this._history[this._history.length] = location;
			this._currentIndex = this._history.length-1;
			
			if (this.autoRefresh)
			{
				this.refresh();
			}
		}
		
		/**
		 * Indicates the auto refresh state, if auto refresh is enabled and if the
		 * <code>location</code> of the <code>Viewport</code> is changed the <code>Viewport</code>
		 * will automatically load the requested SMIL document.
		 */
		public function get autoRefresh():Boolean
		{
			return this._autoRefresh;
		}
		
		/**
		 * Sets the auto refresh state, if auto refresh is enabled and if the
		 * <code>location</code> of the <code>Viewport</code> is changed the <code>Viewport</code>
		 * will automatically load the requested SMIL document.
		 */
		public function set autoRefresh(autoRefresh:Boolean):void
		{
			this._autoRefresh = autoRefresh;
		}
		
		/**
		 * Refreshs the contents of the <code>Viewport</code> based on the current <code>Viewport.location</code>, if the location is updated
		 * and auto-refresh is enabled this method is automatically called. Otherwise the next
		 * time the refresh method is called the new location is used.
		 */
		public function refresh():void
		{
			if (this.location == null || this.location == "")
			{
				throw new IllegalOperationError("Unable to navigate to null location.");
			}
			
			var request:URLRequest = new URLRequest(this.location);
			var loader:URLLoader = new URLLoader();
			
			loader.addEventListener(IOErrorEvent.IO_ERROR, this.onRefreshIOError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onRefreshSecurityError);
			loader.addEventListener(Event.COMPLETE, this.onRefreshComplete);
			
			loader.load(request);
		}
		
		/**
		 * Moves one step back in the history list and sets the location to the old url.
		 */
		public function back():Boolean
		{
			if (this._currentIndex > 0)
			{
				this._currentIndex--;
				
				if (this.autoRefresh)
				{
					this.refresh();
				}
			}
	
			
			return false;
		}
		
		/**
		 * Moves one step forward in the history list and sets the location to the new url.
		 */
		public function forward():Boolean
		{
			if (this._currentIndex < (this._history.length - 1))
			{
				this._currentIndex++;
				
				if (this.autoRefresh)
				{
					this.refresh();
				}
			}
			
			return false;
		}
		
		public function resume():void
		{
			
		}
		
		public function pause():void
		{
			
		}
		
		public function seek(offset:int):void
		{
			
		}
		
		private function onRefreshComplete(e:Event):void
		{
			// destroy the object pool n all its precious children
			if (this._objectPool != null)
			{
				var objectPool:Object = { pool: this._objectPool };
				this._objectPool = null;
				
				// we delete the object pool to avoid a memory leak when re-creating it,
				delete objectPool.pool;
			}
			
			// parse dom
			var document:SMILDocument = (SMILKit.loadSMILDocument(e.target.data) as SMILDocument);
			
			this._objectPool = new ViewportObjectPool(this, document);
			
			this.dispatchEvent(new ViewportEvent(ViewportEvent.REFRESH_COMPLETE));
		}
		
		private function onRefreshIOError(e:IOErrorEvent):void
		{
			
		}
		
		private function onRefreshSecurityError(e:SecurityErrorEvent):void
		{
			
		}
	}
}