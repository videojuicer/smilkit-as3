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
package org.smilkit.view.extensions
{
	import flash.display.Sprite;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import org.smilkit.SMILKit;
	import org.smilkit.dom.Element;
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.dom.smil.SMILMediaElement;
	import org.smilkit.dom.smil.events.SMILMutationEvent;
	import org.smilkit.dom.smil.time.SMILTimeInstance;
	import org.smilkit.events.HandlerControllerEvent;
	import org.smilkit.events.HeartbeatEvent;
	import org.smilkit.events.ViewportEvent;
	import org.smilkit.load.LoadScheduler;
	import org.smilkit.parsers.BostonDOMParser;
	import org.smilkit.render.DrawingBoard;
	import org.smilkit.render.HandlerController;
	import org.smilkit.util.Benchmarks;
	import org.smilkit.w3c.dom.INodeList;
	import org.utilkit.logger.Benchmark;
	import org.utilkit.parser.DataURIParser;
	import org.utilkit.util.Platform;
	import org.smilkit.view.BaseViewport;
	import org.smilkit.view.ViewportObjectPool;

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
	

	public class SMILViewport extends BaseViewport
	{	
		/**
		 *  An instance of ViewportObjectPool responsible for the active documents object pool.
		 */		
		protected var _objectPool:ViewportObjectPool;
		
		/**
		 * Contains the main canvas Sprite to which all RenderTree elements are drawn and displayed
		 */	
		protected var _drawingBoard:DrawingBoard;
		
		/**
		* A flag used to note that an asynchronous operation is in progress on the rendertree, and that playback should be deferred
		* until this operation is complete.
		*/
		protected var _waitingForRenderTree:Boolean = false;
		
		protected var _loader:URLLoader = null;
		
		public function SMILViewport()
		{
			super();

			this._drawingBoard = new DrawingBoard();
			this.addChild(this._drawingBoard);
		}
		
		/**
		 * The current offset for the current <code>Document</code>.
		 */
		public override function get offset():Number
		{
			if (this.document == null)
			{
				return 0;
			}
			
			return this.document.offset;
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
		public function get document():SMILDocument
		{
			if(!this.viewportObjectPool) return null;
			return this.viewportObjectPool.document;
		}
		
		/**
		* Returns the current <code>LoadScheduler</code> object for the active document.
		* @see org.smilkit.load.LoadScheduler
		*/
		public function get loadScheduler():LoadScheduler
		{
			if(!this.document) return null;
			return this.document.loadScheduler;
		}
		
		/**
		 * Returns the current <code>RenderTree</code> object for the active document.
		 * 
		 * @see org.smilkit.render.RenderTree
		 */
		public function get renderTree():HandlerController
		{
			if(!this.viewportObjectPool) return null;
			return this.viewportObjectPool.renderTree;
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
		
		/**
		* Indicates whether the <code>Viewport</code> is waiting for any kind of asynchronous operation to complete
		* before playback can begin.
		*/
		public function get waiting():Boolean
		{
			return this._waitingForRenderTree;
		}
		
		public override function get duration():Number
		{
			if (this.document != null)
			{
				return this.document.duration;
			}
			
			return 0;
		}
		
		/**
		* Indicates that the <code>Viewport</code> is not waiting for any kind of asynchronous operation to complete
		* and that playback can now begin.
		*/
		public function get ready():Boolean
		{
			return !this.waiting;
		}
		
		public override function get boundingRect():Rectangle
		{
			return this.drawingBoard.boundingRect;
		}

		public override function set boundingRect(rect:Rectangle):void
		{
			this.drawingBoard.boundingRect = rect;
		}
		
		/**
		* The Sprite that the Viewport exists inside of, automatically calls
		* addChild on the Sprite and adds the Viewport as a child. Using this
		* still requires the update of <code>boundingRect</code> as Sprites dont issue 
		* resize events. 
		*/
		public function get boundingDisplayPoint():Sprite
		{
			return this.drawingBoard.boundingDisplayParent;
		}
		
		/**
		* Sets the Sprite that the Viewport exists inside of, automatically calls
		* addChild on the Sprite and adds the Viewport as a child. Using this
		* still requires the update of <code>boundingRect</code> as Sprites dont issue 
		* resize events. 
		*/
		public function set boundingDisplayPoint(parent:Sprite):void
		{
			this.drawingBoard.boundingDisplayParent = parent;
		}
		
		public override function get type():String
		{
			return SMILKit.VIEWPORT_SMILKIT;
		}
		
		/**
		 * Refreshs the contents of the <code>Viewport</code> based on the current <code>Viewport.location</code>, if the location is updated
		 * and auto-refresh is enabled this method is automatically called. Otherwise the next
		 * time the refresh method is called the new location is used.
		 */
		public override function refresh():void
		{
			if (this.location == null || this.location == "")
			{
				throw new IllegalOperationError("Unable to navigate to null location.");
			}
			
			if (this._loader != null)
			{
				// a loader exists, and were trying to load something new, so lets kill the old one
				if (this._history.length > 0 && this._history.length >= this._currentIndex)
				{
					this._history.splice(this._currentIndex, 1);
					this._currentIndex = this._history.length;
				}
			}
			

			SMILKit.logger.debug("Pausing playback before refresh", this);
			this.pause();

			// TODO flush display objects
			
			if(this.location.indexOf("data:") == 0)
			{
				SMILKit.logger.benchmark("About to refresh with Data URI.", this);
				this.refreshWithDataURI();
			}
			else
			{
				SMILKit.logger.benchmark("About to refresh with remote URL: "+this.location, this);
				this.refreshWithRemoteURI();
			}
		}
		
		/** 
		* Refreshes the viewport with a remote URI. Only HTTP and HTTPS URIs are supported. 
		*/
		protected function refreshWithRemoteURI():void
		{
			var request:URLRequest = new URLRequest(this.location);
			
			if (this._loader != null)
			{
				this._loader.removeEventListener(IOErrorEvent.IO_ERROR, this.onRefreshWithRemoteURIIOError);
				this._loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onRefreshWithRemoteURISecurityError);
				this._loader.removeEventListener(Event.COMPLETE, this.onRefreshWithRemoteURIComplete);
				
				this._loader.close();
				
				this._loader = null;
			}
			
			this._loader = new URLLoader();
			
			this._loader.addEventListener(IOErrorEvent.IO_ERROR, this.onRefreshWithRemoteURIIOError);
			this._loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onRefreshWithRemoteURISecurityError);
			this._loader.addEventListener(Event.COMPLETE, this.onRefreshWithRemoteURIComplete);
			
			Benchmark.begin(Benchmarks.ORIGIN_SMILKIT, Benchmarks.ORIGIN_SMIL, Benchmarks.ACTION_REQUEST);
			
			this._loader.load(request);
		}
		
		/**
		* Refreshes the viewport with a SMIL document contained within a Data URI. Data URIs are formed like so:
		* data:[{MIME-type}][;charset="{encoding}"][;base64],{data}
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
		* Pulls a piece of metadata from the document by the given key.
		* The metadata must be in a <meta /> tag with the appropriate name key.
		*/
		public override function getDocumentMeta(key:String):String
		{
			if(this.document != null)
			{
				// Commented pending http://www.bugtails.com/projects/253/bugs/1000.html
				//var headNode:Element = this.document.getElementsByTagName("head").item(0) as Element;
				//if(headNode != null)
				//{
					var metaTagList:INodeList = this.document.getElementsByTagName("meta");

					// Loop tags
					for(var i:uint = 0; i < metaTagList.length; i++)
					{
						var metaTag:Element = metaTagList.item(i) as Element;
							if(metaTag.getAttribute("name") == key)
							{
								return metaTag.getAttribute("content");
							}
					}
				//}
			}
			return null;
		}	
		
		/**
		* Sets the <code>Viewport</code>'s volume level, and dispatches a volume changed event if the given newVolume parameter differs from the current
		* volume setting.
		*
		* @param newVolume A <code>uint</code> between 0 and 100 indicating the new desired volume level
		* @param setRestorePoint A <code>Boolean</code> specifying whether the new volume level should be set as a restore point for the next unmute operation.
		*/
		public override function setVolume(newVolume:uint, setRestorePoint:Boolean=false):Boolean
		{
			// Constrain value
			newVolume = Math.max(0, Math.min(BaseViewport.VOLUME_MAX, newVolume));
			
			// Skip if not changed
			if(newVolume != this.volume)
			{
				if(setRestorePoint) this._unmuteRestoreVolume = this.volume;
				var mutedBeforeChange:Boolean = this.muted;

				this._volume = newVolume;

				this.dispatchEvent(new ViewportEvent(ViewportEvent.AUDIO_VOLUME_CHANGED));
				if(newVolume == 0 && !mutedBeforeChange)
				{
					SMILKit.logger.info("Audio muted.", this);	
					this.dispatchEvent(new ViewportEvent(ViewportEvent.AUDIO_MUTED));
				} 
				if(newVolume > 0 && mutedBeforeChange) 
				{
					SMILKit.logger.info("Audio unmuted.", this);
					this.dispatchEvent(new ViewportEvent(ViewportEvent.AUDIO_UNMUTED));
				}
				SMILKit.logger.info("Audio volume changed to "+newVolume+".", this);
				return true;
			}
			else
			{
				return false;
			}
		}
		
		protected function destroyHandlers():void
		{
			if (this.document != null)
			{
				var mediaElements:Vector.<SMILTimeInstance> = this.document.timeGraph.mediaElements;
				
				if (mediaElements != null)
				{
					for (var i:uint = 0; i < mediaElements.length; i++)
					{
						var mediaElement:SMILMediaElement = (mediaElements[i].element as SMILMediaElement);
						
						if (mediaElement != null && mediaElement.handler != null)
						{
							mediaElement.handler.pause();
							mediaElement.handler.destroy();
						}
					}
				}
			}
		}
				
		
		private function refreshObjectPoolWithLoadedData(data:String):void
		{
			if (this._loader != null)
			{
				this._loader.removeEventListener(IOErrorEvent.IO_ERROR, this.onRefreshWithRemoteURIIOError);
				this._loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onRefreshWithRemoteURISecurityError);
				this._loader.removeEventListener(Event.COMPLETE, this.onRefreshWithRemoteURIComplete);
				
				this._loader.close();
				
				this._loader = null;
			}
			
			// destroy the object pool n all its precious children
			if (this._objectPool != null)
			{
				//this.pause();
				
				var objectPool:Object = { pool: this._objectPool };
				
				this.destroyHandlers();

				// Trash old event listeners just in case
				this.document.loadables.removeEventListener(ProgressEvent.PROGRESS, this.onDocumentProgress);
				this.renderTree.removeEventListener(HandlerControllerEvent.WAITING_FOR_DATA, this.onRenderTreeWaitingForData);
				this.renderTree.removeEventListener(HandlerControllerEvent.WAITING_FOR_SYNC, this.onRenderTreeWaitingForSync);
				this.renderTree.removeEventListener(HandlerControllerEvent.READY, this.onRenderTreeReady);
				this.renderTree.removeEventListener(HandlerControllerEvent.ELEMENT_STOPPED, this.onRenderTreeElementStopped);
				// Detach instances from this viewport
				this.renderTree.detach();
				
				this._objectPool = null;
				
				// we delete the object pool to avoid a memory leak when re-creating it,
				delete objectPool.pool;
				
				Platform.garbageCollection();
			}
			
			SMILKit.logger.benchmark("Parsing XML Document into SMILKit's DOM ...");
			
			// parse dom
			var document:SMILDocument = null;
			
			try
			{
				var parser:BostonDOMParser = new BostonDOMParser();
				document = parser.parse(data) as SMILDocument;
			}
			catch (e:Error)
			{
				SMILKit.logger.error("Failed parsing SMIL: "+e.message);
				
				this.dispatchEvent(new ViewportEvent(ViewportEvent.SMIL_PARSE_FAILED));
				
				return;
			}
			
			SMILKit.logger.benchmark("Finished parsing XML Document into DOM");
			
			// Create the object pool with internal timing graph, rendertree etc.
			this._objectPool = new ViewportObjectPool(this, document);
			
			this.document.scheduler.addEventListener(HeartbeatEvent.RUNNING_OFFSET_CHANGED, this.onHeartbeatRunningOffsetChanged);
				
			// Bind events to the newly-created object pool contents
			this.document.addEventListener(SMILMutationEvent.DOM_TIMEGRAPH_MODIFIED, this.onTimingGraphRebuild, false);
			this.document.loadables.addEventListener(ProgressEvent.PROGRESS, this.onDocumentProgress);
		
			this.renderTree.addEventListener(HandlerControllerEvent.WAITING_FOR_DATA, this.onRenderTreeWaitingForData);
			this.renderTree.addEventListener(HandlerControllerEvent.WAITING_FOR_SYNC, this.onRenderTreeWaitingForSync);
			this.renderTree.addEventListener(HandlerControllerEvent.READY, this.onRenderTreeReady);
			this.renderTree.addEventListener(HandlerControllerEvent.ELEMENT_STOPPED, this.onRenderTreeElementStopped);
			
			this.renderTree.addEventListener(HandlerControllerEvent.HANDLER_LOAD_FAILED, this.onHandlerLoadFailed);
			this.renderTree.addEventListener(HandlerControllerEvent.HANDLER_LOAD_UNAUTHORISED, this.onHandlerLoadUnauthorised);
			
			// Shout out REFRESH DONE LOL
			SMILKit.logger.info("Refresh completed with "+data.length+" characters of SMIL data.", this);
			
			this.dispatchEvent(new ViewportEvent(ViewportEvent.REFRESH_COMPLETE));

			// send a playback offset changed event so that addons can reset their UIs
			this.dispatchEvent(new ViewportEvent(ViewportEvent.PLAYBACK_OFFSET_CHANGED));
			
			// tidy up
			Platform.garbageCollection();
		}
		
		protected function onDocumentProgress(e:ProgressEvent):void
		{
			this._bytesLoaded = e.bytesLoaded;
			this._bytesTotal = e.bytesTotal;
			this.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, this._bytesLoaded, this._bytesTotal));
		}
		
		/**
		* Called when the heartbeat's offset changes for any reason, be it a seek, a reset to zero, or a natural progression
		* during playback. Emits a public-facing viewport event.
		*/ 
		protected function onHeartbeatRunningOffsetChanged(e:HeartbeatEvent):void
		{
			this.dispatchEvent(new ViewportEvent(ViewportEvent.PLAYBACK_OFFSET_CHANGED));

			// Check for end of document
			if ((this.document != null) && (!this.waiting) && (e.runningOffset >= this.document.duration) && (this.document.duration > 0))
			{
				SMILKit.logger.info("Stopping at offset: "+e.runningOffset);
				
				this.pause();
				this.dispatchEvent(new ViewportEvent(ViewportEvent.PLAYBACK_COMPLETE));
			}
		}
		
		protected override function onPlaybackStateChangedToPlaying():void
		{
			// If the viewport is not ready, then this operation is deferred until it becomes ready.
			// See onRenderTreeReady for the deferred dispatch to this method.
			// Note that when this method is called by setPlaybackState, the playbackState has already 
			// been altered and it is only the post state-change operation itself that is deferred.
			this.loadScheduler.start();

			if(!this._waitingForRenderTree)
			{				
				SMILKit.logger.info("Completed changing playback state to PLAYBACK_PLAYING.", this);

				if (this.document.scheduler.offset >= this.document.duration && this.document.duration > 0)
				{
					this.seek(0);
					this.commitSeek();
				}
				
				this.document.scheduler.userResume();
			}
			else
			{
				SMILKit.logger.benchmark("Playback state changed to PLAYBACK_PLAYING, but RenderTree is not ready. Waiting for RenderTree to become ready before resuming playback.", this);
			}	
		}
		
		public override function commitSeek():Boolean
		{
			if (this._playbackState == BaseViewport.PLAYBACK_SEEKING)
			{
				this.loadScheduler.start();
				
				return super.commitSeek();
			}
			
			return false;
		}
		
		protected override function onPlaybackStateChangedToPaused():void
		{
			SMILKit.logger.info("Completed changing playback state to PLAYBACK_PAUSED.", this);
			
			if (this.document != null)
			{
				this.document.scheduler.userPause();
				//this.document.scheduler.pause();
			}
		}
		
		protected override function onPlaybackStateChangedToStopped():void
		{
			SMILKit.logger.info("Completed changing playback state to PLAYBACK_STOPPED.", this);
			
			//this.heartbeat.pause();
			//this.heartbeat.seek(0);
			this.document.scheduler.pause();
		}
		
		protected override function onPlaybackStateChangedToSeekingWithOffset(offset:uint):void
		{
			SMILKit.logger.info("Completed changing playback state to PLAYBACK_SEEKING with offset: "+offset+".", this);
			this.loadScheduler.stop();
			//this.heartbeat.pause();
			//this.heartbeat.seek(offset);
			// can rollback this seek: this.heartbeat.rollback();
			
			this.document.scheduler.pause();
			this.document.scheduler.seek(offset);
			
			// update the ui so we know we have seeked
			//this.dispatchEvent(new ViewportEvent(ViewportEvent.PLAYBACK_OFFSET_CHANGED));
		}
		
		protected function onRenderTreeWaitingForData(event:HandlerControllerEvent):void
		{
			SMILKit.logger.info("Waiting for more data to load.", this);
			this._waitingForRenderTree = true;
			//this.heartbeat.pause();
			
			this.document.scheduler.pause();
			
			this.dispatchEvent(new ViewportEvent(ViewportEvent.WAITING));
		}
		
		protected function onRenderTreeWaitingForSync(event:HandlerControllerEvent):void
		{
			SMILKit.logger.info("Waiting for sync before playback can resume.", this);
			this._waitingForRenderTree = true;
			//this.heartbeat.pause();
			
			this.document.scheduler.pause();
			
			this.dispatchEvent(new ViewportEvent(ViewportEvent.WAITING));
		}
		
		protected function onRenderTreeReady(event:HandlerControllerEvent):void
		{
			// If the state is PLAYBACK_PLAYING, then we need to execute the deferred state change now.
			if(this._waitingForRenderTree)
			{
				SMILKit.logger.info("Ready to play.", this);
				this._waitingForRenderTree = false;
				
				if(this._playbackState == BaseViewport.PLAYBACK_PLAYING)
				{
					SMILKit.logger.info("Playback was deferred because the Viewport was waiting for another operation to complete. Resuming playback now.", this);
					
					this.onPlaybackStateChangedToPlaying();
				}				
			}				
			
			this.dispatchEvent(new ViewportEvent(ViewportEvent.READY));
		}
		
		protected function onRenderTreeElementStopped(event:HandlerControllerEvent):void
		{
			SMILKit.logger.debug("Render tree got complete/stopped event from "+event.handler+", about to perform out-of-band heartbeat pulse", this);
			
			//this.heartbeat.beat();
			//this.document.scheduler.triggerTickNow();
		}
		
		protected function onTimingGraphRebuild(event:SMILMutationEvent):void
		{
			SMILKit.logger.debug("Document mutated.", this);
			
			this.dispatchEvent(new ViewportEvent(ViewportEvent.DOCUMENT_MUTATED));
		}
		
		private function onRefreshWithRemoteURIComplete(e:Event):void
		{
			Benchmark.finish(Benchmarks.ORIGIN_SMILKIT, Benchmarks.ORIGIN_SMIL, Benchmarks.ACTION_REQUEST);
			
			SMILKit.logger.benchmark("Finished loading remote document, about to refresh viewport objects.", this);
			this.refreshObjectPoolWithLoadedData(e.target.data);
		}
		
		private function onRefreshWithRemoteURIIOError(e:IOErrorEvent):void
		{
			Benchmark.finish(Benchmarks.ORIGIN_SMILKIT, Benchmarks.ORIGIN_SMIL, Benchmarks.ACTION_REQUEST);
			
			SMILKit.logger.fatal("Could not load remote document because of an IO Error.", this);
			
			this.dispatchEvent(new ViewportEvent(ViewportEvent.LOADER_IOERROR));
		}
		
		private function onRefreshWithRemoteURISecurityError(e:SecurityErrorEvent):void
		{
			Benchmark.finish(Benchmarks.ORIGIN_SMILKIT, Benchmarks.ORIGIN_SMIL, Benchmarks.ACTION_REQUEST);
			
			SMILKit.logger.fatal("Could not load remote document because of a Security Error.", this);
			
			this.dispatchEvent(new ViewportEvent(ViewportEvent.LOADER_SECURITY_ERROR));
		}
		
		private function onHandlerLoadFailed(e:HandlerControllerEvent):void
		{
			this.dispatchEvent(new ViewportEvent(ViewportEvent.HANDLER_LOAD_FAILED));
		}
		
		private function onHandlerLoadUnauthorised(e:HandlerControllerEvent):void
		{
			this.dispatchEvent(new ViewportEvent(ViewportEvent.HANDLER_LOAD_UNAUTHORISED));
		}
		
		public override function dispose():void
		{
			if (this.loadScheduler != null)
			{
				this.loadScheduler.stop();
			}
			
			this.destroyHandlers();
			
			super.dispose();
		}
	}
}