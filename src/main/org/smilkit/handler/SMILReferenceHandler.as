package org.smilkit.handler
{
	import com.hurlant.util.asn1.parser.nulll;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Rectangle;
	
	import org.smilkit.SMILKit;
	import org.smilkit.dom.events.MutationEvent;
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.dom.smil.SMILRefElement;
	import org.smilkit.dom.smil.Time;
	import org.smilkit.events.HandlerEvent;
	import org.smilkit.events.ViewportEvent;
	import org.smilkit.parsers.BostonDOMParser;
	import org.smilkit.parsers.BostonDOMParserEvent;
	import org.smilkit.render.HandlerController;
	import org.smilkit.util.MathHelper;
	import org.smilkit.view.Viewport;
	import org.smilkit.view.ViewportObjectPool;
	import org.smilkit.w3c.dom.IElement;
	import org.smilkit.w3c.dom.INodeList;

	
	/**
	 * BIG CHANGE HERE:
	 * 
	 * - reference handler loads a new Viewport
	 * - handler relays events back and forth between the handler + inner viewport
	 */
	
	/**
	* The SMILReferenceHandler is intended to act as a primary media handler for reference tags
	* which load external SMIL documents into the context of a parent document:
	*
	* <code><pre><ref type="application/smil" src="http://foo.com/bar.smil" /></pre></code>
	*
	* DOM Referencing
	* ---------------
	* SMILKit's DOM instantiates these reference nodes as SMILReferenceElement instances, which are a
	* special type of ElementTimeContainer with handling for injecting and removing referenced SMIL
	* content from the DOM.
	*
	* Caching and invalidation
	* ------------------------
	* Referenced SMIL documents, while sometimes used for refactoring large or complex SMIL presentations,
	* are often used by content delivery networks to deliver references to assets with signed, time-limited
	* URLs. This presents a cache invalidation issue where the contents of a referenced SMIL document is 
	* likely to become invalid if the user's connection drops, or after a pause in playback.
	*
	* To support use cases like this, the SMILReferenceHandler acts as an invalidator for any loaded SMIL
	* content within a reference element. The behaviour is as follows:
	*
	* 1. Referenced SMIL documents are loaded in a just-in-time fashion just like any other asset type.
	* 2. Once loaded, the contents of the external SMIL document are considered valid until either:
	*	a. 	The SMILReferenceElement is removed from the RenderTree. Unlike most other handler types,
	*		this handler will reload its content each and every time it is added to the RenderTree's
	*		list of active elements. The content is marked as invalid when the handler is removed from
	*		the RenderTree's active list.
	*	b.	The Viewport's playback state changes to *paused*. Heartbeat pauses triggered by wait/sync
	*		cycles are not counted. The content will be reloaded when playback is resumed.
	*/
	
	public class SMILReferenceHandler extends SMILKitHandler
	{
		protected var _viewport:Viewport = null;
		
		protected var _resuming:Boolean = false;
		
		protected var _contentValid:Boolean = false;
		
		/**
		* Tracks whether the element is currently active on the RenderTree.
		*/
		protected var _activeOnRenderTree:Boolean = false;
		
		/**
		* Tracks whether the document content should be invalidated on the next viewport resume.
		*/
		protected var _invalidateOnNextResume:Boolean = false;

		public function SMILReferenceHandler(element:IElement)
		{
			super(element);
			
			this._viewport = new Viewport();
			
			this._viewport.addEventListener(ViewportEvent.READY, this.onViewportReady);
			this._viewport.addEventListener(ViewportEvent.WAITING, this.onViewportWaiting);
			
			this._viewport.addEventListener(ViewportEvent.PLAYBACK_STATE_CHANGED, this.onViewportPlaybackStateChanged);
			
			this._viewport.addEventListener(ViewportEvent.DOCUMENT_MUTATED, this.onViewportDocumentMutated);
			
			this._viewport.addEventListener(ViewportEvent.LOADER_IOERROR, this.onViewportLoaderIOError);
			this._viewport.addEventListener(ViewportEvent.LOADER_SECURITY_ERROR, this.onViewportLoaderSecurityError);
			
			this._viewport.addEventListener(ViewportEvent.REFRESH_COMPLETE, this.onViewportRefreshComplete);	
		}
		
		public override function get resolvable():Boolean
		{
			return true;
		}
		
		public override function get preloadable():Boolean
		{
			return false;
		}
		
		public override function get displayObject():DisplayObject
		{
			return this._viewport;
		}
		
		public function get contentValid():Boolean
		{
			return this._contentValid;
		}
		
		public override function get spatial():Boolean
		{
			return true;
		}
		
		public override function get temporal():Boolean
		{
			return true;
		}
		
		public override function get seekable():Boolean
		{
			return true;
		}
		
		public override function get currentOffset():int
		{
			if (this.isViewportSMILReady)
			{
				return (this._viewport.offset * 1000);
			}
			
			return 0;
		}
		
		public override function get completedResolving():Boolean
		{
			var duration:Number = this.viewport.document.duration;
			
			return (duration != Time.UNRESOLVED && duration != Time.MEDIA);
		}
		
		public override function get completedLoading():Boolean
		{
			return false;
		}
		
		public override function get width():uint
		{
			if (this._region != null)
			{
				return this._region.regionContainer.width;
			}
			
			return 100;
		}
		
		public override function get height():uint
		{
			if (this._region != null)
			{
				return this._region.regionContainer.height;
			}
			
			return 100;
		}
		
		public function get viewport():Viewport
		{
			return this._viewport;
		}
		
		public function get isViewportSMILReady():Boolean
		{
			return (this.viewport.document != null);
		}
		
		public override function load():void
		{
			this._viewport.location = this.element.src;
			
			this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_WAITING, this));
		}
		
		public override function resume():void
		{
			if (this.isViewportSMILReady)
			{
				this._viewport.resume();
			}
			else
			{
				this._resuming = true;
			}
		}

		public override function pause():void
		{
			if (this.isViewportSMILReady)
			{
				this._viewport.pause();
			}
		}
		
		public override function seek(seekTo:Number):void
		{
			if (this.isViewportSMILReady)
			{
				this._viewport.seek(seekTo);
				this._viewport.commitSeek();
			}
		}
		
		public override function setVolume(volume:uint):void
		{
			this._viewport.setVolume(volume);
		}
		
		public override function resize():void
		{
			if (this.region != null)
			{
				this._viewport.boundingRect = new Rectangle(0, 0, this.region.regionContainer.width, this.region.regionContainer.height);
			}
		}
		
		/**
		* Marks the content of this SMIL reference element as invalid. If the handler is currently
		* active on the render tree, the invalidation will trigger a reload. Give (true) as the
		* argument for this method if you wish to force a reload of the document contents.
		*/
		public function invalidate(hardInvalidation:Boolean = false):void
		{
			var hadStartedLoading:Boolean = this._startedLoading;
			var hadCompletedLoading:Boolean = this._completedLoading;
			
			this._contentValid = false;
			this._startedLoading = false;
			this._completedLoading = false;
			
			if ((this._activeOnRenderTree || hardInvalidation) && ((!hadStartedLoading) || (hadStartedLoading && hadCompletedLoading)))
			{
				var msg:String = "Performing hard invalidation with reload as ref handler is ";
				
				if(this._activeOnRenderTree) msg += "[active on the RenderTree]";
				if(hardInvalidation) msg += "[explicitly hard-invalidating]";
				if(!hadStartedLoading) msg += "[not already loaded]";
				if(hadStartedLoading && hadCompletedLoading) msg += "[already completed loading]";
				
				SMILKit.logger.debug(msg, this);
				
				this.load();
			}
			else
			{
				SMILKit.logger.debug("Performing soft invalidation on SMILReferenceHandler load flags (active: "+this._activeOnRenderTree+" hadStarted: "+hadStartedLoading+", hadCompleted: "+hadCompletedLoading+")", this);
			}
		}
		
		public override function addedToRenderTree(r:HandlerController):void
		{
			this._activeOnRenderTree = true;
		}
		
		public override function removedFromRenderTree(r:HandlerController):void
		{
			this._activeOnRenderTree = false;
			
			this.invalidate();
		}
		
		protected function onViewportRefreshComplete(e:ViewportEvent):void
		{
			if (this._resuming)
			{
				this._viewport.resume();
				
				this._resuming = false;
			}
			else
			{
				this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_READY, this));
			}
		}
		
		protected function onViewportReady(e:ViewportEvent):void
		{			
			this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_READY, this));
		}
		
		protected function onViewportWaiting(e:ViewportEvent):void
		{
			this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_WAITING, this));
		}
		
		protected function onViewportPlaybackStateChanged(e:ViewportEvent):void
		{
			if (this._viewport.playbackState == Viewport.PLAYBACK_PAUSED)
			{
				SMILKit.logger.debug("Caught viewport pause. This reference handler will invalidate on the next resume.", this);
				
				this._invalidateOnNextResume = true;
			}
			else if (this._viewport.playbackState == Viewport.PLAYBACK_PLAYING)
			{
				// TODO - this is wrong. the element must be on the rendertree for this to be valid.
				if(this._invalidateOnNextResume)
				{
					//this.invalidate();
				}
				
				this._invalidateOnNextResume = false;
			}
			
			if (this._viewport.playbackState == Viewport.PLAYBACK_PLAYING)
			{
				this.dispatchEvent(new HandlerEvent(HandlerEvent.RESUME_NOTIFY, this));
			}
			else if (this._viewport.playbackState == Viewport.PLAYBACK_PAUSED)
			{
				this.dispatchEvent(new HandlerEvent(HandlerEvent.PAUSE_NOTIFY, this));
			}
		}
		
		protected function onViewportDocumentMutated(e:ViewportEvent):void
		{
			this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_READY, this));
		}
		
		protected function onViewportLoaderIOError(e:ViewportEvent):void
		{
			this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_FAILED, this));
		}
		
		protected function onViewportLoaderSecurityError(e:ViewportEvent):void
		{
			this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_UNAUTHORISED, this));
		}
		
		public static function toHandlerMap():HandlerMap
		{
			return new HandlerMap([ 'http', 'https' ], { 'application/smil': [ '.smil', '*' ], 'application/smil+xml': [ '.smil' ] });
		}
	}
	
//	public class SMILReferenceHandler extends SMILKitHandler
//	{
//		protected var _contentValid:Boolean = false;
//		protected var _referenceElement:SMILRefElement;
//		protected var _viewport:Viewport;
//		protected var _parser:BostonDOMParser;
//		
//		/**
//		* Tracks whether the element is currently active on the RenderTree.
//		*/
//		protected var _activeOnRenderTree:Boolean = false;
//		
//		/**
//		* Tracks whether the document content should be invalidated on the next viewport resume.
//		*/
//		protected var _invalidateOnNextResume:Boolean = false;
//		
//		/**
//		* A shim that gives the rendertree a virtual sprite to place for this handler.
//		*/
//		protected var _sprite:Sprite;
//		
//		public function SMILReferenceHandler(element:IElement)
//		{
//			super(element);
//			this._sprite = new Sprite();
//			this.bindInvalidationListeners();
//		}
//		
//		public override function get resolvable():Boolean
//		{
//			return false;
//		}
//		
//		public override function get preloadable():Boolean
//		{
//			return false;
//		}
//		
//		public override function get displayObject():DisplayObject
//		{
//			return (this._sprite as DisplayObject);
//		}
//		
//		public function get contentValid():Boolean
//		{
//			return this._contentValid;
//		}
//		
//		/** 
//		* Provides load behaviour for the reference handler. Content is only loaded if the 
//		* content is currently invalid. If the content is invalidated, the load flags are also reset.
//		*/
//		public override function load():void
//		{
//			if(this._contentValid)
//			{
//				SMILKit.logger.debug("Skipping reload of external SMIL document - existing content remains valid.", this);
//			}
//			else
//			{
//				this.bindInvalidationListeners();
//				var src:String = this.element.getAttribute("src").toString();
//				
//				SMILKit.logger.debug("Starting load of external SMIL document from "+src+" - content is invalid or unloaded.", this);
//				// Create loader
//				this._parser = new BostonDOMParser();
//
//				// Bind loader events
//				this._parser.addEventListener(BostonDOMParserEvent.PARSER_COMPLETE, this.onDocumentParseComplete);
//				this._parser.addEventListener(IOErrorEvent.IO_ERROR, this.onDocumentLoadIOError);
//				this._parser.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onDocumentLoadSecurityError);
//				this._parser.addEventListener(Event.COMPLETE, this.onDocumentLoadCompleted);
//				
//				// Dispatch the load event
//				this._startedLoading = true;
//				this.onDocumentLoadStarted();
//				
//				// Flush element children
//				if(this.element != null)
//				{
//					var e:IElement = this.element;
//					var smilElements:INodeList = e.getElementsByTagName("smil");
//					if (e.hasChildNodes() && smilElements.length > 0)
//					{
//						for (var i:int = 0; i < smilElements.length; i++)
//						{
//							e.removeChild(smilElements.item(i));
//						}
//					}
//				}
//				
//				// Kickstart loader
//				this._parser.load(src, this.element);
//			}
//		}
//		
//		protected function bindInvalidationListeners():void
//		{
//			if(this.element != null)
//			{
//				this._referenceElement = (this.element as SMILRefElement);
//				if(this.element.ownerDocument != null)
//				{
//					var objectPool:ViewportObjectPool = (this.element.ownerDocument as SMILDocument).viewportObjectPool;
//					if(objectPool != null)
//					{
//						this._viewport = objectPool.viewport;
//					}
//				}
//				else
//				{
//					SMILKit.logger.warn("Given element has no owning document - this reference will have problems invalidating.", this);
//				}
//			}
//			else
//			{
//				SMILKit.logger.error("Instantiated without a matching element, will be unable to perform DOM updates", this);
//			}
//			
//			
//			// Bind to viewport
//			if(this._viewport != null)
//			{
//				this._viewport.removeEventListener(ViewportEvent.PLAYBACK_STATE_CHANGED, this.onViewportPlaybackStateChanged);
//				this._viewport.addEventListener(ViewportEvent.PLAYBACK_STATE_CHANGED, this.onViewportPlaybackStateChanged);
//			}
//			
//			if(this.element != null)
//			{
//				// Bind to element for mutations to src attribute
//				this.element.removeEventListener(MutationEvent.DOM_ATTR_MODIFIED, this.onElementAttributeModified, false);
//				this.element.addEventListener(MutationEvent.DOM_ATTR_MODIFIED, this.onElementAttributeModified, false); // third argument is useCapture, not optional under w3c spec. See smilkit's Node class.
//			}
//		}
//		
//		/**
//		* Marks the content of this SMIL reference element as invalid. If the handler is currently
//		* active on the render tree, the invalidation will trigger a reload. Give (true) as the
//		* argument for this method if you wish to force a reload of the document contents.
//		*/
//		public function invalidate(hardInvalidation:Boolean = false):void
//		{
//			var hadStartedLoading:Boolean = this._startedLoading;
//			var hadCompletedLoading:Boolean = this._completedLoading;
//			
//			this._contentValid = false;
//			this._startedLoading = false;
//			this._completedLoading = false;
//			
//			if((this._activeOnRenderTree || hardInvalidation) && ((!hadStartedLoading) || (hadStartedLoading && hadCompletedLoading)))
//			{
//				var msg:String = "Performing hard invalidation with reload as ref handler is ";
//				if(this._activeOnRenderTree) msg += "[active on the RenderTree]";
//				if(hardInvalidation) msg += "[explicitly hard-invalidating]";
//				if(!hadStartedLoading) msg += "[not already loaded]";
//				if(hadStartedLoading && hadCompletedLoading) msg += "[already completed loading]";
//				
//				SMILKit.logger.debug(msg, this);
//				this.load();
//			}
//			else
//			{
//				SMILKit.logger.debug("Performing soft invalidation on SMILReferenceHandler load flags (active: "+this._activeOnRenderTree+" hadStarted: "+hadStartedLoading+", hadCompleted: "+hadCompletedLoading+")", this);
//			}
//		}
//		
//		protected function onElementAttributeModified(e:MutationEvent):void
//		{
//			if (e.attrName == "src" || e.attrName == "type")
//			{
//				if (e.prevValue != e.newValue)
//				{
//					this.invalidate();
//				}
//			}
//		}
//		
//		protected function onDocumentLoadStarted():void
//		{
//			SMILKit.logger.debug("Started loading external SMIL document.", this);
//			this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_WAITING, this));
//		}
//		
//		protected function onDocumentLoadCompleted(e:Event):void
//		{
//			SMILKit.logger.debug("Finished loading external SMIL document, waiting for parser to finish...", this);
//		}
//		
//		protected function onDocumentLoadIOError(e:IOErrorEvent):void
//		{
//			SMILKit.logger.error("I/O error when attempting to load external SMIL document", this);
//			this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_FAILED, this));
//		}
//		
//		protected function onDocumentLoadSecurityError(e:SecurityErrorEvent):void
//		{
//			SMILKit.logger.error("Security error when attempting to load external SMIL document", this);
//			this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_FAILED, this));
//		}
//		
//		protected function onDocumentParseComplete(e:BostonDOMParserEvent):void
//		{
//			SMILKit.logger.debug("Finished parsing external SMIL document injecting new markup. Reference load completed.", this);
//			
//			this._contentValid = true; // validate the content
//			this._completedLoading = true;
//			
//			// Unresolve the entire document
//			if(this.element != null)
//			{
//				// REPLACE IF TIMING GRAPH IS FAILING TO INVALIDATE 
//				// ((this.element.ownerDocument as SMILDocument).timeChildren as ElementTimeNodeList).unresolve();
//			}
//			
//			this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_READY, this));
//			this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_COMPLETED, this));
//		}
//		
//		public override function addedToRenderTree(r:HandlerController):void
//		{
//			this._activeOnRenderTree = true;
//		}
//		
//		public override function removedFromRenderTree(r:HandlerController):void
//		{
//			this._activeOnRenderTree = false;
//			this.invalidate();
//		}
//		
//		protected function onViewportPlaybackStateChanged(e:ViewportEvent):void
//		{
//			if(this._viewport.playbackState == Viewport.PLAYBACK_PAUSED)
//			{
//				SMILKit.logger.debug("Caught viewport pause. This reference handler will invalidate on the next resume.", this);
//				this._invalidateOnNextResume = true;
//			}
//			else if(this._viewport.playbackState == Viewport.PLAYBACK_PLAYING)
//			{
//				// TODO - this is wrong. the element must be on the rendertree for this to be valid.
//				if(this._invalidateOnNextResume)
//				{
//					this.invalidate();
//				}
//				this._invalidateOnNextResume = false;
//			}
//		}
//		
//		public static function toHandlerMap():HandlerMap
//		{
//			return new HandlerMap([ 'http', 'https' ], { 'application/smil': [ '.smil', '*' ], 'application/smil+xml': [ '.smil' ] });
//		}
//	}
}