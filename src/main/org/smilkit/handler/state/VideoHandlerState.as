package org.smilkit.handler.state
{
	import flash.display.Sprite;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import org.utilkit.parser.FMSURLParser;
	import org.utilkit.parser.URLParser;

	public class VideoHandlerState extends HandlerState
	{
		protected var _netConnection:NetConnection;
		protected var _netStream:NetStream;
		protected var _video:Video;
		protected var _canvas:Sprite;
		
		protected var _fmsURLParser:FMSURLParser;
		
		public function VideoHandlerState(src:String, handlerOffset:int, netConnection:NetConnection, netStream:NetStream, video:Video, canvas:Sprite)
		{
			super(src, handlerOffset);
			
			this._netConnection = netConnection;
			this._netStream = netStream;
			this._video = video;
			this._canvas = canvas;
		}
		
		public function get netConnection():NetConnection
		{
			return this._netConnection;
		}
		
		public function get netStream():NetStream
		{
			return this._netStream;
		}
		
		public function get fmsURL():FMSURLParser
		{
			if (this._fmsURLParser == null)
			{
				this._fmsURLParser = new FMSURLParser(this.src);
			}
			
			return this._fmsURLParser;
		}
		
		public function get video():Video
		{
			return this._video;
		}
		
		public function get canvas():Sprite
		{
			return this._canvas;
		}
		
		public override function get type():String
		{
			return "video";
		}
		
		public override function compatibleWith(handlerState:HandlerState):Boolean
		{
			if (super.compatibleWith(handlerState))
			{
				if (this.extractedSrc.host == handlerState.extractedSrc.host)
				{
					return true;
				}
			}
			
			return false;
		}
	}
}