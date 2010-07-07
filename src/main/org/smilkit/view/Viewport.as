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
	import org.smilkit.w3c.dom.smil.ISMILDocument;
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.util.DataURIParser;

	import org.smilkit.events.TimingGraphEvent;
	import org.smilkit.events.ViewportEvent;
	import org.smilkit.events.RenderTreeEvent;

	import org.smilkit.load.LoadScheduler;
	import org.smilkit.render.DrawingBoard;
	import org.smilkit.render.RenderTree;
	import org.smilkit.time.Heartbeat;
	import org.smilkit.time.TimingGraph;

	/**
	 * Dispatched when the <code>Viewport</code> instance has refreshed with a new document.
	 * When this event is dispatched, the <code>Viewport</code> will have brand new <code>TimingGraph</code>, <code>RenderTree</code>
	 * and <code>LoadScheduler</code> instances, so you'll have to rebind any event listeners you need to the new objects.
	 *
	 * @eventType org.smilkit.events.ViewportEvent.REFRESH_COMPLETE
	 */
	[Event(name="viewportRefreshComplete", type="org.smilkit.events.ViewportEvent")]
	
	/**
	 * Dispatched when the <code>Viewport</code> instance changes playback state. Call myViewportInstance.playbackState
	 * to get the new playback state.
	 *
	 * @eventType org.smilkit.events.ViewportEvent.PLAYBACK_STATE_CHANGED
	 */
	[Event(name="viewportPlaybackStateChanged", type="org.smilkit.events.ViewportEvent")]
	
	/**
	 * Dispatched when the any of the <code>Viewport</code> instance's current set of media handlers dispatches
	 * "waiting for data" event of it's own - e.g. a stream is buffering, an image is loading etc.
	 * 
	 * While waiting for data, the <code>Viewport</code>'s playback is halted (although the playback state will not
	 * change to "paused"), and playback will resume automatically once all currently-active media handlers have 
	 * reported ready, if the <code>Viewport</code> is currently playing.
	 *
	 * @eventType org.smilkit.events.ViewportEvent.WAITING_FOR_DATA
	 */
	[Event(name="viewportWaitingForData", type="org.smilkit.events.ViewportEvent")]
	
	/**
	 * Dispatched when all the <code>Viewport</code>'s currently-active media handlers have loaded enough data for
	 * playback to continue.
	 *
	 * @eventType org.smilkit.events.ViewportEvent.READY
	 */
	[Event(name="viewportReady", type="org.smilkit.events.ViewportEvent")]
	
	/**
	 * Dispatched when the <code>Viewport</code>'s document is altered by an asset's duration being resolved, a SMIL 
	 * submission completing or any other internal process. When this event is dispatched it is advisable to query the
	 * document in case it's duration has changed so that you can update your application's user interface appropriately.
	 *
	 * @eventType org.smilkit.events.ViewportEvent.DOCUMENT_MUTATED
	 */
	[Event(name="viewportDocumentMutated", type="org.smilkit.events.ViewportEvent")]
	

	public class Viewport extends EventDispatcher
	{
		
		public static var PLAYBACK_PLAYING:String = "playbackPlaying";
		public static var PLAYBACK_PAUSED:String = "playbackPaused";
		public static var PLAYBACK_SEEKING:String = "playbackSeeking";
		
		public static var SEEK_UNCOMMITTED:String = "seekTransient";
		public static var SEEK_COMMITTED:String = "seekCommitted";
		
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
		
		/**
		* The current playback state for this Viewport instance.
		*/
		protected var _playbackState:String;
		
		/**
		* The previous playback state for this Viewport instance. Toggle methods use this to store a state to which the viewport should be restored.
		*/
		protected var _previousPlaybackState:String;
		
		/**
		* The offset last seeked to when in PLAYBACK_SEEKING state. Switching to a state other than PLAYBACK_SEEKING will reset this variable.
		*/
		protected var _previousUncommittedSeekOffset:int = -1;
		
		public function Viewport()
		{
			this._history = new Vector.<String>();
			this._heartbeat = new Heartbeat(Heartbeat.BPS_5);
			this._drawingBoard = new DrawingBoard();
			this.pause();
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
		* Public getter for the internal _playbackState variable
		*/
		public function get playbackState():String
		{
			return this._playbackState;
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
			
			if(this.location.indexOf("data:") == 0)
			{
				this.refreshWithDataURI();
			}
			else
			{
				this.refreshWithRemoteURI();
			}
		}
		
		/** 
		* Refreshes the viewport with a remote URI. Only HTTP and HTTPS URIs are supported. 
		*/
		protected function refreshWithRemoteURI():void
		{
			var request:URLRequest = new URLRequest(this.location);
			var loader:URLLoader = new URLLoader();
			
			loader.addEventListener(IOErrorEvent.IO_ERROR, this.onRefreshWithRemoteURIIOError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onRefreshWithRemoteURISecurityError);
			loader.addEventListener(Event.COMPLETE, this.onRefreshWithRemoteURIComplete);
			
			loader.load(request);
		}
		
		/**
		* Refreshes the viewport with a SMIL document contained within a Data URI. Data URIs are formed like so:
		* data:[<MIME-type>][;charset="<encoding>"][;base64],<data>
		* for example with utf-8 escaped markup:
		* data:application/smil;charset=utf-8,ESCAPED_SMIL
		* or with Base64-encoded markup:
		* data:application/smil;base64,BASE_64_ENCODED_SMIL
		*/
		protected function refreshWithDataURI():void
		{
			
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
		
		/**
		* Begins or resumes playback from the current playhead position.
		* @return A <code>Boolean</code> value. True if the playback state changed successfully, false otherwise..
		*/
		public function resume():Boolean
		{
			return this.setPlaybackState(Viewport.PLAYBACK_PLAYING);
		}
		
		/**
		* Pauses playback at the current playhead position.
		* @return A <code>Boolean</code> value. True if the playback state changed successfully, false otherwise..
		*/		
		public function pause():Boolean
		{
			return this.setPlaybackState(Viewport.PLAYBACK_PAUSED);
		}
		
		/**
		* Performs a seek to the given offset within the document. Calling this method throws the viewport instance into
		* a "seeking" playback state, during which certain special behaviours apply - in particular, while in this state the
		* viewport will not do any just-in-time loading of assets.
		* @return A <code>Boolean</code> value. True if the playback state changed successfully, false otherwise..
		*/
		public function seek(offset:uint):Boolean
		{
			return this.setPlaybackState(Viewport.PLAYBACK_SEEKING, offset);
		}
		
		/**
		* Reverts the viewport from a seeking state back to the previously-active playback state. You should call commitSeek()
		* after any sequence of seek(offset) calls. For instance when implementing a basic drag and drop slider UI for seeking,
		* you would call seek(offset) each time the user moves the play head during a drag operation and commitSeek() when the user
		* releases the playhead.
		* @return A <code>Boolean</code> value. True if the playback state changed successfully, false otherwise..
		*/
		public function commitSeek():Boolean
		{
			if(this._playbackState == Viewport.PLAYBACK_SEEKING)
			{
				this.revertPlaybackState();
				return true;
			}
			else
			{
				return false;
			}
		}
		
		/**
		* Alters the playback state of the viewport instance to the given value.
		* If the playback state already matches the given value, nothing happens and false is returned.
		* If the given value is a new playback state, the playback state is set and a state change event is dispatched. True will be returned.
		* There is a special case for registering a state change while the viewport's state is PLAYBACK_SEEKING. In this state, a state change will 
		* be registered if *either* the newState or offset arguments differ from the last call.
		*/
		public function setPlaybackState(newState:String, offset:uint=0):Boolean
		{
			if(newState != this._playbackState)
			{
				// Register a basic state change
				this._previousPlaybackState = this._playbackState;
				this._playbackState = newState;
				switch(this._playbackState)
				{
					case Viewport.PLAYBACK_PLAYING:
						this._previousUncommittedSeekOffset = -1;
						this.onPlaybackStateChangedToPlaying();
						break;
					case Viewport.PLAYBACK_PAUSED:
						this._previousUncommittedSeekOffset = -1;
						this.onPlaybackStateChangedToPaused();
						break;
					case Viewport.PLAYBACK_SEEKING:
						this._previousUncommittedSeekOffset = offset;
						this.onPlaybackStateChangedToSeekingWithOffset(offset);
						break;
				}
				this.dispatchEvent(new ViewportEvent(ViewportEvent.PLAYBACK_STATE_CHANGED));
				return true;
			}
			else if(newState == Viewport.PLAYBACK_SEEKING && this._previousUncommittedSeekOffset != offset)
			{
				// Register a special case for changing offset while seeking
				this._previousUncommittedSeekOffset = offset;
				this.onPlaybackStateChangedToSeekingWithOffset(offset);
				this.dispatchEvent(new ViewportEvent(ViewportEvent.PLAYBACK_STATE_CHANGED));
				return true;
			}
			else
			{
				return false;
			}
		}
		
		private function refreshObjectPoolWithLoadedData(data:String):void
		{
			// destroy the object pool n all its precious children
			if (this._objectPool != null)
			{
				var objectPool:Object = { pool: this._objectPool };
				this._objectPool = null;
				
				// Trash old event listeners just in case
				this.timingGraph.removeEventListener(TimingGraphEvent.REBUILD, this.onTimingGraphRebuild);
				this.renderTree.removeEventListener(RenderTreeEvent.WAITING_FOR_DATA, this.onRenderTreeWaitingForData);
				this.renderTree.removeEventListener(RenderTreeEvent.READY, this.onRenderTreeReady);
				
				// we delete the object pool to avoid a memory leak when re-creating it,
				delete objectPool.pool;
			}
			
			// parse dom
			var document:SMILDocument = (SMILKit.loadSMILDocument(data) as SMILDocument);
			
			this._objectPool = new ViewportObjectPool(this, document);
			
			// Bind events to the newly-created objects
			this.timingGraph.addEventListener(TimingGraphEvent.REBUILD, this.onTimingGraphRebuild);
			this.renderTree.addEventListener(RenderTreeEvent.WAITING_FOR_DATA, this.onRenderTreeWaitingForData);
			this.renderTree.addEventListener(RenderTreeEvent.READY, this.onRenderTreeReady);
			
			this.dispatchEvent(new ViewportEvent(ViewportEvent.REFRESH_COMPLETE));
		}
		
		/**
		* Reverts the playback state to the value stored during the last successful changePlaybackState call.
		*/
		public function revertPlaybackState():void
		{
			this.setPlaybackState(this._previousPlaybackState);
		}
		
		protected function onPlaybackStateChangedToPlaying():void
		{
			this.loadScheduler.start();
			this.heartbeat.resume();
		}
		
		protected function onPlaybackStateChangedToPaused():void
		{
			this.heartbeat.pause();
		}
		
		protected function onPlaybackStateChangedToSeekingWithOffset(offset:uint):void
		{
			this.heartbeat.pause();
			this.heartbeat.seek(offset);
			// can rollback this seek: this.heartbeat.rollback();
		}
		
		protected function onRenderTreeWaitingForData(event:RenderTreeEvent):void
		{
			this.heartbeat.pause();
			this.dispatchEvent(new ViewportEvent(ViewportEvent.WAITING_FOR_DATA));
		}
		
		protected function onRenderTreeReady(event:RenderTreeEvent):void
		{
			if(this._playbackState == Viewport.PLAYBACK_PLAYING) this.heartbeat.resume();
			this.dispatchEvent(new ViewportEvent(ViewportEvent.READY));
		}
		
		protected function onTimingGraphRebuild(event:TimingGraphEvent):void
		{
			this.dispatchEvent(new ViewportEvent(ViewportEvent.DOCUMENT_MUTATED));
		}
		
		private function onRefreshWithRemoteURIComplete(e:Event):void
		{
			this.refreshObjectPoolWithLoadedData(e.target.data);
		}
		
		private function onRefreshWithDataURIComplete():void
		{
			
		}
		
		private function onRefreshWithRemoteURIIOError(e:IOErrorEvent):void
		{
			
		}
		
		private function onRefreshWithRemoteURISecurityError(e:SecurityErrorEvent):void
		{
			
		}
	}
}