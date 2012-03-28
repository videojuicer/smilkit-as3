package org.smilkit.view
{
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import org.smilkit.SMILKit;
	import org.smilkit.events.ViewportEvent;
	import org.utilkit.util.Platform;
	
	public class BaseViewport extends Sprite
	{
		public static var PLAYBACK_PLAYING:String = "playbackPlaying";
		public static var PLAYBACK_PAUSED:String = "playbackPaused";
		public static var PLAYBACK_SEEKING:String = "playbackSeeking";
		
		public static var SEEK_UNCOMMITTED:String = "seekTransient";
		public static var SEEK_COMMITTED:String = "seekCommitted";
		
		public static var VOLUME_MAX:uint = 100;
		
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
		protected var _volume:uint = 0;
		
		/**
		 * The volume to which audio should be restored when unmuting. If null, <code>BaseViewport.VOLUME_MAX</code> will be used.
		 */
		protected var _unmuteRestoreVolume:uint;
		
		/**
		 * Flags stored when the document's loader progress is updated
		 */
		protected var _bytesLoaded:int = 0;
		protected var _bytesTotal:int = 0;
		
		protected var _autoPlay:Boolean = false;
		
		public function BaseViewport()
		{
			super();
			
			this._history = new Vector.<String>();
			
			this.pause();
		}
		
		/**
		 * <code>Rectangle</code> that specifies the points at which the <code>Viewport</code> is drawn, the x + y params
		 * of <code>Rectangle</code> are ignored.
		 */
		public function get boundingRect():Rectangle
		{
			return null;
		}
		
		/**
		 * Sets the bounding <code>Rectangle</code> that specifies the points at which the Viewport is drawn
		 * too, the x + y params of <code>Rectangle</code> are ignored.
		 */
		public function set boundingRect(rect:Rectangle):void
		{
			
		}
		
		public function get offset():Number
		{
			return 0;
		}
		
		public function get duration():Number
		{
			return 0;
		}
		
		/**
		 * Indicates whether the <code>Viewport</code> is playing or not.
		 */
		public function get playing():Boolean
		{
			return this.playbackState == BaseViewport.PLAYBACK_PLAYING;
		}
		
		public function getDocumentMeta(key:String):String
		{
			return null;
		}
		
		public function get bytesLoaded():int
		{
			if (this._bytesTotal == 0)
			{
				return 0;
			}
			
			return this._bytesLoaded;
		}
		
		public function get bytesTotal():int
		{
			return this._bytesTotal;
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
		 * Sets the URL location for the <code>Viewport</code> location, will auto load the requested
		 * location unless <code>autoRefresh</code> is set to false. The location may be set as a regular
		 * URL, or as a W3C data URI with the utf-8 character set. Data URIs may optionally be base64-encoded.
		 * 
		 * If <code>autoRefresh</code> is set to false, you must call <code>refresh</code> after setting the
		 * location in order to load the new document.
		 *
		 * @see org.smilkit.view.BaseViewport.autoRefresh
		 * @see org.smilkit.view.BaseViewport.refresh
		 */
		public function set location(location:String):void
		{			
			if (location == this.location)
			{
				SMILKit.logger.debug("Location re-set to existing value ("+location+" -> "+this.location+"), about to refresh", this);
				
				this.refresh();
				
				return;
			}
			
			var i:int = this._history.indexOf(location);
			
			if (this._history.length > 0 && (this._currentIndex < (this._history.length - 1)))
			{
				this._history = this._history.slice(08, this._currentIndex + 1);
			}
			
			this._history.push(location);
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
		
		public function get autoPlay():Boolean
		{
			return this._autoPlay;
		}
		
		public function set autoPlay(autoPlay:Boolean):void
		{
			this._autoPlay = autoPlay;
		}
		
		/**
		 * Public getter for the internal <code>_playbackState</code> variable.
		 *
		 * Note that the playbackState is not indicative of the <code>Viewport</code>'s *readiness*. For example,
		 * if more data needs to be loaded during playback, <code>playbackState</code> will still return <code>BaseViewport.PLAYBACK_PLAYING</code>
		 * even though the playhead itself is currently held awaiting more data. Use <code>waiting</code> or <code>ready</code> to determine if
		 * the <code>Viewport</code> is currently waiting on any internal actions to complete before resuming.
		 *
		 * @see org.smilkit.view.BaseViewport.waiting
		 * @see org.smilkit.view.BaseViewport.ready
		 */
		public function get playbackState():String
		{
			return this._playbackState;
		}
		
		public function get isVolatile():Boolean
		{
			return false;
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
			return (this._unmuteRestoreVolume)? this._unmuteRestoreVolume : BaseViewport.VOLUME_MAX;
		}	
		
		/** 
		 * Public getter for the current mute toggle state for this <code>Viewport</code> instance.
		 * @return A <code>Boolean</code>, true if the viewport is currently muted.
		 */
		public function get muted():Boolean
		{
			return (this.volume <= 0);
		}
		
		public function get type():String
		{
			return null;
		}
		
		public function refresh():void
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
			return this.setPlaybackState(BaseViewport.PLAYBACK_PLAYING);
		}
		
		/**
		 * Pauses playback at the current playhead position.
		 * @return A <code>Boolean</code> value. True if the playback state changed successfully, false otherwise..
		 */		
		public function pause():Boolean
		{
			return this.setPlaybackState(BaseViewport.PLAYBACK_PAUSED);
		}
		
		/**
		 * Performs a seek to the given offset within the document. Calling this method throws the viewport instance into
		 * a "seeking" playback state, during which certain special behaviours apply - in particular, while in this state the
		 * viewport will not do any just-in-time loading of assets.
		 * @return A <code>Boolean</code> value. True if the playback state changed successfully, false otherwise..
		 */
		public function seek(offset:uint):Boolean
		{
			return this.setPlaybackState(BaseViewport.PLAYBACK_SEEKING, offset);
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
				SMILKit.logger.info("Playback state set to to "+newState+".", this);
				
				// Register a basic state change
				this._previousPlaybackState = this._playbackState;
				this._playbackState = newState;
				
				switch(this._playbackState)
				{
					case BaseViewport.PLAYBACK_PLAYING:
						this._previousUncommittedSeekOffset = -1;
						this.onPlaybackStateChangedToPlaying();
						break;
					case BaseViewport.PLAYBACK_PAUSED:
						this._previousUncommittedSeekOffset = -1;
						this.onPlaybackStateChangedToPaused();
						break;
					case BaseViewport.PLAYBACK_SEEKING:
						this._previousUncommittedSeekOffset = offset;
						this.onPlaybackStateChangedToSeekingWithOffset(offset);
						break;
				}
				
				this.dispatchEvent(new ViewportEvent(ViewportEvent.PLAYBACK_STATE_CHANGED));
				
				return true;
			}
			else if(newState == BaseViewport.PLAYBACK_SEEKING && this._previousUncommittedSeekOffset != offset)
			{
				SMILKit.logger.info("Playback state set to "+newState+" (offset: "+offset+").", this);
				
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
		 * Reverts the viewport from a seeking state back to the previously-active playback state. You should call commitSeek()
		 * after any sequence of seek(offset) calls. For instance when implementing a basic drag and drop slider UI for seeking,
		 * you would call seek(offset) each time the user moves the play head during a drag operation and commitSeek() when the user
		 * releases the playhead.
		 * @return A <code>Boolean</code> value. True if the playback state changed successfully, false otherwise..
		 */
		public function commitSeek():Boolean
		{
			SMILKit.logger.info("Seek operation committed. Reverting to previous playback state at offset: "+this.offset, this);
			if(this._playbackState == BaseViewport.PLAYBACK_SEEKING)
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
		 * Reverts the playback state to the value stored during the last successful changePlaybackState call.
		 */
		public function revertPlaybackState():void
		{
			SMILKit.logger.debug("About to revert playback state to "+this._previousPlaybackState+".", this);	
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
		
		public function setVolume(volume:uint, setRestorePoint:Boolean = false):Boolean
		{
			return false;
		}
		
		public function dispose():void
		{
			this.pause();
			
			Platform.garbageCollection();
		}
		
		protected function onPlaybackStateChangedToPlaying():void
		{
			
		}
		
		protected function onPlaybackStateChangedToPaused():void
		{
			
		}
		
		protected function onPlaybackStateChangedToStopped():void
		{
			
		}
		
		protected function onPlaybackStateChangedToSeekingWithOffset(offset:uint):void
		{
			
		}
	}
}