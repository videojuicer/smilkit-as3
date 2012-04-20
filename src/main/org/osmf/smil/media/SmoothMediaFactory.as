package org.osmf.smil.media
{
	import org.osmf.elements.AudioElement;
	import org.osmf.elements.F4MElement;
	import org.osmf.elements.F4MLoader;
	import org.osmf.elements.ImageElement;
	import org.osmf.elements.ImageLoader;
	import org.osmf.elements.SoundLoader;
	import org.osmf.elements.VideoElement;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.net.MulticastNetLoader;
	import org.osmf.net.NetLoader;
	import org.osmf.net.dvr.DVRCastNetLoader;
	import org.osmf.net.httpstreaming.HTTPStreamingNetLoader;
	import org.osmf.net.rtmpstreaming.RTMPDynamicStreamingNetLoader;
	import org.osmf.smil.elements.SMILElement;
	import org.osmf.smil.loader.SMILLoader;
	
	public class SmoothMediaFactory extends MediaFactory
	{
		public function SmoothMediaFactory()
		{
			super();
			
			this.init();
		}
		
		private function init():void
		{
			this._f4mLoader = new F4MLoader(this);
			this.addItem 
			( new MediaFactoryItem
				( "org.osmf.elements.f4m"
					, this._f4mLoader.canHandleResource
					, function():MediaElement
					{
						return new F4MElement(null, _f4mLoader);
					}
				)
			);
			
			this._dvrCastLoader = new DVRCastNetLoader();
			this.addItem
			( new MediaFactoryItem
				( "org.osmf.elements.video.dvr.dvrcast"
					, this._dvrCastLoader.canHandleResource
					, function():MediaElement
					{
						var video:VideoElement = new VideoElement(null, _dvrCastLoader);
						video.smoothing = true;
						video.deblocking = 1;
						
						return video;
					}
				)
			);
			
			this._httpStreamingNetLoader = new HTTPStreamingNetLoader();
			this.addItem
			( new MediaFactoryItem
				( "org.osmf.elements.video.httpstreaming"
					, this._httpStreamingNetLoader.canHandleResource
					, function():MediaElement
					{
						var video:VideoElement = new VideoElement(null, _httpStreamingNetLoader);
						video.smoothing = true;
						video.deblocking = 1;
						
						return video;
					}
				)
			);
			
			this._multicastLoader = new MulticastNetLoader();
			this.addItem
			( new MediaFactoryItem
				( "org.osmf.elements.video.rtmfp.multicast"
					, this._multicastLoader.canHandleResource
					, function():MediaElement
					{
						var video:VideoElement = new VideoElement(null, _multicastLoader);
						video.smoothing = true;
						video.deblocking = 1;
						
						return video;
					}
				)
			);
			
			this._rtmpStreamingNetLoader = new RTMPDynamicStreamingNetLoader();
			this.addItem
			( new MediaFactoryItem
				( "org.osmf.elements.video.rtmpdynamicStreaming"
					, this._rtmpStreamingNetLoader.canHandleResource
					, function():MediaElement
					{
						var video:VideoElement = new VideoElement(null, _rtmpStreamingNetLoader);
						video.smoothing = true;
						video.deblocking = 1;
						
						return video;
					}
				)
			);
			
			this._netLoader = new NetLoader();
			this.addItem
			( new MediaFactoryItem
				( "org.osmf.elements.video"
					, this._netLoader.canHandleResource
					, function():MediaElement
					{
						var video:VideoElement = new VideoElement(null, _netLoader);
						video.smoothing = true;
						video.deblocking = 1;
						
						return video;
					}
				)
			);    
			
			this._soundLoader = new SoundLoader();
			this.addItem
			( new MediaFactoryItem
				( "org.osmf.elements.audio"
					, this._soundLoader.canHandleResource
					, function():MediaElement
					{
						return new AudioElement(null, _soundLoader);
					}
				)
			);
			
			this.addItem
			( new MediaFactoryItem
				( "org.osmf.elements.audio.streaming"
					, this._netLoader.canHandleResource
					, function():MediaElement
					{
						return new AudioElement(null, _netLoader);
					}
				)
			);
			
			this._imageLoader = new ImageLoader();
			this.addItem
			( new MediaFactoryItem
				( "org.osmf.elements.image"
					, this._imageLoader.canHandleResource
					, function():MediaElement
					{
						return new ImageElement(null, _imageLoader);
					}
				)
			);
		}
		
		private var _rtmpStreamingNetLoader:RTMPDynamicStreamingNetLoader;
		private var _f4mLoader:F4MLoader;
		private var _dvrCastLoader:DVRCastNetLoader;
		private var _netLoader:NetLoader;
		private var _imageLoader:ImageLoader;
		private var _soundLoader:SoundLoader;
		private var _httpStreamingNetLoader:HTTPStreamingNetLoader;
		private var _multicastLoader:MulticastNetLoader;
	}
}