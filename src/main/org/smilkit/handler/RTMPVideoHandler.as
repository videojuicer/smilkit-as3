package org.smilkit.handler
{
	import flash.events.NetStatusEvent;
	
	import org.smilkit.w3c.dom.IElement;
	
	public class RTMPVideoHandler extends SMILKitHandler
	{
		public function RTMPVideoHandler(element:IElement)
		{
			super(element);
		}
		
		protected function onNetStatusEvent(e:NetStatusEvent):void
		{
			switch (e.info.code)
			{
				case "NetStream.Buffer.Full":
					this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_READY, this));
					break;
				case "NetStream.Buffer.Empty":
					this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_WAITING, this));
					break;
				case "NetStream.Failed":
				case "NetStream.Play.Failed":
				case "NetStream.Play.NoSupportedTrackFound":
				case "NetStream.Play.FileStructureInvalid":
					this.dispatchEvent(new HandlerEvent(HandlerEvent.LOAD_FAILED, this));
					break;
				case "NetStream.Unpublish.Success":
				case "NetStream.Play.Stop":
					// playback has finished, important for live events (so we can continue)
					break;
				case "NetStream.Play.InsufficientBW":
					break;
				case "NetStream.Pause.Notify":
					break;
				case "NetStream.Unpause.Notify":
					break;
				case "NetStream.Seek.Failed":
					this.dispatchEvent(new HandlerEvent(HandlerEvent.SEEK_FAILED, this));
					break;
				case "NetStream.Seek.InvalidTime":
					this.dispatchEvent(new HandlerEvent(HandlerEvent.SEEK_INVALID, this));
					break;
				case "NetStream.Seek.Notify":
					this.dispatchEvent(new HandlerEvent(HandlerEvent.SEEK_COMPLETED, this));
					break;
			}
		}
	}
}