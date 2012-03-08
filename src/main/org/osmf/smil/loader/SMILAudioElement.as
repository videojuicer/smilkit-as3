package org.osmf.smil.loader
{
	import org.osmf.elements.AudioElement;
	import org.osmf.media.URLResource;
	import org.osmf.net.NetStreamLoadTrait;
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
				this.removeTrait(MediaTraitType.SEEK);
				
				var timeTrait:TimeTrait = new AudioNetStreamTimeTrait(netLoadTrait.connection, netLoadTrait.netStream, this.resource, this.defaultDuration);
				
				this.addTrait(MediaTraitType.TIME, timeTrait);
				this.addTrait(MediaTraitType.SEEK, new AudioNetStreamSeekTrait(timeTrait, netLoadTrait, netLoadTrait.netStream));
			}
		}
	}
}