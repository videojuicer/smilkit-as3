package org.osmf.smil.loader
{
	import org.osmf.elements.VideoElement;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.net.NetLoader;
	import org.osmf.net.httpstreaming.HTTPStreamingNetLoader;
	import org.osmf.net.rtmpstreaming.RTMPDynamicStreamingNetLoader;
	import org.osmf.traits.LoaderBase;
	
	public class SMILVideoElement extends VideoElement
	{
		public function SMILVideoElement(arg0:MediaResourceBase=null, arg1:NetLoader=null)
		{
			super(arg0, arg1);
		}
		
		public override function set resource(value:MediaResourceBase):void
		{
			loader = this.getLoaderForResource(value, this.alternateLoaders);
			
			super.resource = value;
		}
		
		// Internals
		//
		
		private function get alternateLoaders():Vector.<LoaderBase>
		{
			if (_alternateLoaders == null)
			{
				_alternateLoaders = new Vector.<LoaderBase>()
				
				// Order matters.
				_alternateLoaders.push(new HTTPStreamingNetLoader());
				_alternateLoaders.push(new RTMPDynamicStreamingNetLoader());
				_alternateLoaders.push(new NetLoader());
			}
			
			return _alternateLoaders;
		}
		
		private var _alternateLoaders:Vector.<LoaderBase>;
	}
}