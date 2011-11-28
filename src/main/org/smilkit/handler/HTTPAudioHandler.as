package org.smilkit.handler
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.media.ID3Info;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	
	import org.smilkit.events.HandlerEvent;
	import org.smilkit.w3c.dom.IElement;
	
	public class HTTPAudioHandler extends SMILKitHandler
	{
		protected var _sound:Sound = null;
		protected var _soundLoaderContext:SoundLoaderContext = null;
		
		protected var _soundTransform:SoundTransform = null;
		protected var _soundChannel:SoundChannel = null;
		
		protected var _lastPosition:Number = 0;
		
		protected var _canvas:Sprite = null;
		
		public function HTTPAudioHandler(element:IElement)
		{
			super(element);
			
			this._canvas = new Sprite();
		}
		
		public override function get displayObject():DisplayObject
		{
			return (this._canvas as DisplayObject);
		}
		
		public override function get spatial():Boolean
		{
			return false;
		}
		
		public override function get temporal():Boolean
		{
			return true;
		}
		
		public override function get seekable():Boolean
		{
			return true;
		}
		
		public override function get resolvable():Boolean
		{
			return true;
		}
		
		public override function load():void
		{
			this._sound = new Sound();
			
			this._sound.addEventListener(ProgressEvent.PROGRESS, this.onLoaderProgress);
			this._sound.addEventListener(Event.ID3, this.onID3Tags);
			this._sound.addEventListener(Event.COMPLETE, this.onLoaderComplete);
			this._sound.addEventListener(IOErrorEvent.IO_ERROR, this.onLoaderIOError);

			this._soundTransform = new SoundTransform();
			this._soundTransform.volume = (this.viewportObjectPool.viewport.volume / 100);
			
			this._sound.load(new URLRequest(this.element.src));
			
			this._startedLoading = true;
			
			this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_WAITING, this));
		}
		
		public override function setVolume(volume:uint):void
		{
			if (this._soundTransform != null)
			{
				this._soundTransform.volume = (volume / 100);
				
				if (this._soundChannel != null)
				{
					this._soundChannel.soundTransform = this._soundTransform;
				}
			}
		}
		
		public override function resume():void
		{
			if (this._sound != null)
			{
				super.resume();
				
				this.resumeFrom(this._lastPosition);
			
				this.dispatchEvent(new HandlerEvent(HandlerEvent.RESUME_NOTIFY, this));
			}
		}
		
		public override function pause():void
		{
			if (this._sound != null)
			{
				super.pause();
				
				if (this._soundChannel != null)
				{
					this._lastPosition = this._soundChannel.position;
				
					this._soundChannel.stop();
					this._soundChannel = null;
				}
				
				this.dispatchEvent(new HandlerEvent(HandlerEvent.PAUSE_NOTIFY, this));
			}
		}
		
		public override function seek(target:Number, strict:Boolean):void
		{
			super.seek(target, strict);
			
			if (this._sound != null)
			{
				if (!this.resumed)
				{
					this._lastPosition = target;
				}
				else
				{
					this.resumeFrom(target);
			
					this.dispatchEvent(new HandlerEvent(HandlerEvent.SEEK_NOTIFY, this));
				}
			}
		}
		
		public override function cancel():void
		{
			super.cancel();
			
			if (this._soundChannel != null)
			{
				this._soundChannel.stop();
				this._soundChannel = null;
			}
			
			this._sound.close();
		}
		
		protected function resumeFrom(target:Number):void
		{
			if (this._soundChannel != null)
			{
				this._soundChannel.stop();
				this._soundChannel = null;
			}
			
			this._soundChannel = this._sound.play(target, 0, this._soundTransform);
			this._soundChannel.addEventListener(Event.SOUND_COMPLETE, this.onSoundComplete);
			
			// record where we start from
			this._lastPosition = target;
		}
		
		protected function onLoaderProgress(e:ProgressEvent):void
		{
			if(this._mediaElement != null)
			{
				this._mediaElement.intrinsicBytesLoaded = this._sound.bytesLoaded;
				this._mediaElement.intrinsicBytesTotal = this._sound.bytesTotal;
			}
		}
		
		protected function onID3Tags(e:Event):void
		{
			
		}
		
		protected function onLoaderComplete(e:Event):void
		{
			this.resolved(this._sound.length);
			
			this._completedLoading = true;
			
			if(this._mediaElement != null)
			{
				this._mediaElement.intrinsicBytesLoaded = this._sound.bytesLoaded;
				this._mediaElement.intrinsicBytesTotal = this._sound.bytesTotal;
			}
			
			this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_READY, this));
		}
		
		protected function onLoaderIOError(e:IOErrorEvent):void
		{
			this.cancel();
			
			this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_FAILED, this));
		}
		
		protected function onSoundComplete(e:Event):void
		{
			this.dispatchEvent(new HandlerEvent(HandlerEvent.STOP_NOTIFY, this));
		}
		
		public static function toHandlerMap():HandlerMap
		{
			return new HandlerMap(['http'], { 'audio/mp3': [ '.mp3' ] });
		}
	}
}