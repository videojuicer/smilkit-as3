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
	 * Dispatched when the <code>Viewport</code>'s playhead position changes, either through a natural progression during
	 * playback or through any kind of seek operation.
	 *
	 * @eventType org.smilkit.events.ViewportEvent.PLAYBACK_OFFSET_CHANGED
	 */
	[Event(name="viewportPlaybackOffsetChanged", type="org.smilkit.events.ViewportEvent")]
	
	
	/**
	 * Dispatched when the <code>Viewport</code> is in a state where it must perform any kind of asynchronous
	 * operation before playback at the current offset can continue. This could be loading or buffering an asset,  
	 * or waiting for asset synchronisation when resuming from a seek operation.
	 *
	 * @eventType org.smilkit.events.ViewportEvent.WAITING
	 */
	[Event(name="viewportWaiting", type="org.smilkit.events.ViewportEvent")]
	
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
	
	/**
	 * Dispatched when the <code>Viewport</code>'s audio volume is set to 0, either via the mute() method or
	 * by setting the <code>Viewport</code>'s volume to 0.
	 *
	 * @eventType org.smilkit.events.ViewportEvent.AUDIO_MUTED
	 */
	[Event(name="viewportAudioMuted", type="org.smilkit.events.ViewportEvent")]
	
	/**
	 * Dispatched when the <code>Viewport</code>'s audio volume is set to a value higher than 0, if the viewport
	 * was muted before the volume was set.
	 * 
	 * @eventType org.smilkit.events.ViewportEvent.AUDIO_UNMUTED
	 */
	[Event(name="viewportAudioUnmuted", type="org.smilkit.events.ViewportEvent")]
	
	/**
	 * Dispatched when the <code>Viewport</code>'s audio volume is changed by any mechanism.
	 *
	 * @eventType org.smilkit.events.ViewportEvent.AUDIO_VOLUME_CHANGED
	 */
	[Event(name="viewportAudioVolumeChanged", type="org.smilkit.events.ViewportEvent")]
	

	public class Viewport extends EventDispatcher
	{
		
		public static var PLAYBACK_PLAYING:String = "playbackPlaying";
		public static var PLAYBACK_PAUSED:String = "playbackPaused";
		public static var PLAYBACK_SEEKING:String = "playbackSeeking";
		
		public static var SEEK_UNCOMMITTED:String = "seekTransient";
		public static var SEEK_COMMITTED:String = "seekCommitted";
		
		public static var VOLUME_MAX:uint = 100;
		
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
		
		/**
		*  The current audio output volume.
		*/
		protected var _volume:uint = 100;
		
		/**
		* The volume to which audio should be restored when unmuting. If null, <code>Viewport.VOLUME_MAX</code> will be used.
		*/
		protected var _unmuteRestoreVolume:uint;		
		
		/**
		* A flag used to note that an asynchronous operation is in progress on the rendertree, and that playback should be deferred
		* until this operation is complete.
		*/
		protected var _waitingForRenderTree:Boolean = false;
		
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
			return this.playbackState == Viewport.PLAYBACK_PLAYING;
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
		 * location unless <code>autoRefresh</code> is set to false. The location may be set as a regular
		 * URL, or as a W3C data URI with the utf-8 character set. Data URIs may optionally be base64-encoded.
		 * 
		 * If <code>autoRefresh</code> is set to false, you must call <code>refresh</code> after setting the
		 * location in order to load the new document.
		 *
		 * @see org.smilkit.view.Viewport.autoRefresh
		 * @see org.smilkit.view.Viewport.refresh
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
		* Public getter for the internal <code>_playbackState</code> variable
		*/
		public function get playbackState():String
		{
			return this._playbackState;
		}
		
		/**
		* Indicates whether the <code>Viewport</code> is waiting for any kind of asynchronous operation to complete
		* before playback can begin.
		*/
		public function get waiting():Boolean
		{
			return this._waitingForRenderTree;
		}
		
		/**
		* Indicates that the <code>Viewport</code> is not waiting for any kind of asynchronous operation to complete
		* and that playback can now begin.
		*/
		public function get ready():Boolean
		{
			return !this.waiting;
		}
		
		/**
		* Sets the audio volume for this <code>Viewport</code> instance. 
		* Accepts a <code>uint</code> between 0 and 100, with 0 being muted and 100 being maximum volume.
		*/
		public function set volume(volume:uint):void
		{
			this.setVolume(volume);
		}
		
		/**
		* Returns the viewport's current volume level as a uint between 0 and 100, with 0 being muted
		* and 100 being maximum volume.
		*/
		public function get volume():uint
		{
			return this._volume;
		}	
		
		/**
		* Returns the value to which volume will be set when unmute() is next called. This is the value
		* last set by a call to setVolume with the setRestorePoint argument given as true, or the max
		* volume level if no restore point has been set.
		*/
		public function get unmuteRestoreVolume():uint
		{
			return (this._unmuteRestoreVolume)? this._unmuteRestoreVolume : Viewport.VOLUME_MAX;
		}	
		
		/** 
		* Public getter for the current mute toggle state for this <code>Viewport</code> instance.
		* @return A <code>Boolean</code>, true if the viewport is currently muted.
		*/
		public function get muted():Boolean
		{
			return (this.volume <= 0);
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
			var parser:DataURIParser = new DataURIParser(this.location);
			this.refreshObjectPoolWithLoadedData(parser.data);
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
		
		/**
		* Reverts the playback state to the value stored during the last successful changePlaybackState call.
		*/
		public function revertPlaybackState():void
		{
			this.setPlaybackState(this._previousPlaybackState);
		}
		
		/**
		* Mutes all audio output from this viewport instance, saving the current volume level as a restore
		* point.
		*
		* @params setRestorePoint A <code>Boolean</code> specifying whether the current volume level should be used as a restore point when unmuting.
		*/
		public function mute(setRestorePoint:Boolean=false):Boolean
		{
			return this.setVolume(0, setRestorePoint);
		}
		
		/**
		* Returns the <code>Viewport</code> from a muted state, returning the volume level to the last volume restore point, or to the maximum volume
		* if no restore point has been set.
		*/
		public function unmute():Boolean
		{
			return this.setVolume(this.unmuteRestoreVolume);
		}
		
		/**
		* Toggles the <code>Viewport</code> between a muted and unmuted state.
		* 
		* @params setRestorePoint A <code>Boolean</code> specifying whether the current volume level should be used as a restore point when unmuting.
		*/
		public function toggleMute(setRestorePoint:Boolean=false):Boolean
		{
			return (this.muted)? this.unmute() : this.mute(setRestorePoint);
		}
		
		/**
		* Sets the <code>Viewport</code>'s volume level, and dispatches a volume changed event if the given newVolume parameter differs from the current
		* volume setting.
		*
		* @param newVolume A <code>uint</code> between 0 and 100 indicating the new desired volume level
		* @param setRestorePoint A <code>Boolean</code> specifying whether the new volume level should be set as a restore point for the next unmute operation.
		*/
		public function setVolume(newVolume:uint, setRestorePoint:Boolean=false):Boolean
		{
			// Constrain value
			newVolume = Math.max(0, Math.min(Viewport.VOLUME_MAX, newVolume));
			
			// Skip if not changed
			if(newVolume != this.volume)
			{
				if(setRestorePoint) this._unmuteRestoreVolume = this.volume;
				var mutedBeforeChange:Boolean = this.muted;

				this._volume = newVolume;

				this.dispatchEvent(new ViewportEvent(ViewportEvent.AUDIO_VOLUME_CHANGED));
				if(newVolume == 0 && !mutedBeforeChange) this.dispatchEvent(new ViewportEvent(ViewportEvent.AUDIO_MUTED));
				if(newVolume > 0 && mutedBeforeChange) this.dispatchEvent(new ViewportEvent(ViewportEvent.AUDIO_UNMUTED));
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
				this.renderTree.removeEventListener(RenderTreeEvent.WAITING_FOR_SYNC, this.onRenderTreeWaitingForSync);
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
			this.renderTree.addEventListener(RenderTreeEvent.WAITING_FOR_SYNC, this.onRenderTreeWaitingForSync);
			this.renderTree.addEventListener(RenderTreeEvent.READY, this.onRenderTreeReady);
			
			this.dispatchEvent(new ViewportEvent(ViewportEvent.REFRESH_COMPLETE));
		}
		
		protected function onPlaybackStateChangedToPlaying():void
		{
			// If the viewport is not ready, then this operation is deferred until it becomes ready.
			// See onRenderTreeReady for the deferred dispatch to this method.
			// Note that when this method is called by setPlaybackState, the playbackState has already 
			// been altered and it is only the post state-change operation itself that is deferred.
			if(!this._waitingForRenderTree)
			{
				this.loadScheduler.start();
				this.heartbeat.resume();
			}			
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
			this._waitingForRenderTree = true;
			this.heartbeat.pause();
			this.dispatchEvent(new ViewportEvent(ViewportEvent.WAITING));
		}
		
		protected function onRenderTreeWaitingForSync(event:RenderTreeEvent):void
		{
			this._waitingForRenderTree = true;
			this.heartbeat.pause();
			this.dispatchEvent(new ViewportEvent(ViewportEvent.WAITING));
		}
		
		protected function onRenderTreeReady(event:RenderTreeEvent):void
		{
			// If the state is PLAYBACK_PLAYING, then we need to execute the deferred state change now.
			if(this._waitingForRenderTree && this._playbackState == Viewport.PLAYBACK_PLAYING) this.onPlaybackStateChangedToPlaying();
			this._waitingForRenderTree = false;			
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
		
		private function onRefreshWithRemoteURIIOError(e:IOErrorEvent):void
		{
			
		}
		
		private function onRefreshWithRemoteURISecurityError(e:SecurityErrorEvent):void
		{
			
		}
	}
}