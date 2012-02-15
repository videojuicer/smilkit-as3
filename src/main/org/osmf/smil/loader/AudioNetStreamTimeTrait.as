package org.osmf.smil.loader
{
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.Responder;
	
	import org.osmf.media.MediaResourceBase;
	import org.osmf.net.NetStreamTimeTrait;
	
	public class AudioNetStreamTimeTrait extends NetStreamTimeTrait
	{
		public function AudioNetStreamTimeTrait(netConnection:NetConnection, netStream:NetStream, resource:MediaResourceBase, defaultDuration:Number=NaN)
		{
			super(netStream, resource, defaultDuration);
			
			var responder:Responder = new Responder(this.onStreamLength, this.onStreamLengthStatus);
			
			netConnection.call("getStreamLength", responder, "mp3:labs/3b499da4-16bd-11e1-bb64-1231380f32af");
		}
		
		protected function onStreamLength(length:Number):void
		{
			this.setDuration(length);
		}
		
		protected function onStreamLengthStatus(info:Object):void
		{
			
		}
	}
}