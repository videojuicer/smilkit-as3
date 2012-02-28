package org.osmf.smil.loader
{
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.Responder;
	
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.net.NetStreamTimeTrait;
	import org.osmf.net.NetStreamUtils;
	
	public class AudioNetStreamTimeTrait extends NetStreamTimeTrait
	{
		public function AudioNetStreamTimeTrait(netConnection:NetConnection, netStream:NetStream, resource:MediaResourceBase, defaultDuration:Number=NaN)
		{
			super(netStream, resource, defaultDuration);
			
			var urlResource:URLResource = (resource as URLResource);
			var streamName:String = NetStreamUtils.getStreamNameFromURL(urlResource.url);
			
			var responder:Responder = new Responder(this.onStreamLength, this.onStreamLengthStatus);
			
			if (streamName != null && streamName != "")
			{
				netConnection.call("getStreamLength", responder, streamName);
			}
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