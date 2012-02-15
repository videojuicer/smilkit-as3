package org.osmf.smil.loader
{
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.Responder;
	
	import org.osmf.elements.AudioElement;
	import org.osmf.media.URLResource;
	import org.osmf.net.NetStreamLoadTrait;
	import org.osmf.net.NetStreamTimeTrait;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.TimeTrait;
	
	public class SMILAudioElement extends AudioElement
	{
		public function SMILAudioElement(resource:URLResource=null, loader:LoaderBase=null)
		{
			super(resource, loader);
		}
		
		protected override function processReadyState():void
		{
			super.processReadyState();
			
			var loadTrait:LoadTrait = getTrait(MediaTraitType.LOAD) as LoadTrait;
			var netLoadTrait:NetStreamLoadTrait = loadTrait as NetStreamLoadTrait;
			
			if (netLoadTrait != null)
			{
				this.removeTrait(MediaTraitType.TIME);
				
				var timeTrait:TimeTrait = new AudioNetStreamTimeTrait(netLoadTrait.connection, netLoadTrait.netStream, this.resource, this.defaultDuration);
				this.addTrait(MediaTraitType.TIME, timeTrait);
			}
		}
	}
}