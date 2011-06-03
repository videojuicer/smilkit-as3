package org.smilkit.handler
{
	import flash.events.NetStatusEvent;
	import flash.net.Responder;
	
	import org.smilkit.SMILKit;
	import org.smilkit.w3c.dom.IElement;
	
	public class RTMPAudioHandler extends RTMPVideoHandler
	{
		protected var _lengthRequested:Boolean = false;
		
		public function RTMPAudioHandler(element:IElement)
		{
			super(element);
		}
		
		public override function get fileSizeWillResolve():Boolean
		{
			return false;
		}
		
		public override function get width():uint
		{
			return super.width;
		}
		
		public override function get height():uint
		{
			return super.height;
		}
		
		public override function get spatial():Boolean
		{
			return false;
		}
		
		protected override function onConnectionNetStatusEvent(e:NetStatusEvent):void
		{
			if (!this._lengthRequested)
			{
				var responder:Responder = new Responder(this.onGetStreamLength, this.onGetStreamLengthStatus);
				
				this._netConnection.call("getStreamLength", responder, this.videoHandlerState.fmsURL.streamNameWithParameters);
				this._lengthRequested = true;
			}
			
			super.onConnectionNetStatusEvent(e);
		}
		
		protected function onGetStreamLength(length:Number):void
		{
			SMILKit.logger.debug("Received RTMP audio stream length: "+length);
			
			this.resolved(length * 1000);
		}
		
		protected function onGetStreamLengthStatus(info:Object):void
		{
			SMILKit.logger.debug("Stream Status: "+info.toString());
		}
		
		public static function toHandlerMap():HandlerMap
		{
			return new HandlerMap([ 'rtmp', 'rtmpt', 'rtmps', 'rtmpe' ], { 'audio/mp3': [ '.mp3' ] });
		}
	}
}