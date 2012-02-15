package org.osmf.smil.loader
{
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.MediaType;
	import org.osmf.media.MediaTypeUtil;
	import org.osmf.net.NetConnectionFactoryBase;
	import org.osmf.net.NetLoader;
	
	public class AudioNetLoader extends NetLoader
	{
		public function AudioNetLoader(factory:NetConnectionFactoryBase=null)
		{
			super(factory);
		}
		
		public override function canHandleResource(resource:MediaResourceBase):Boolean
		{
			var rt:int = MediaTypeUtil.checkMetadataMatchWithResource(resource, MEDIA_TYPES_SUPPORTED, MIME_TYPES_SUPPORTED);
			
			if (rt != MediaTypeUtil.METADATA_MATCH_UNKNOWN)
			{
				return rt == MediaTypeUtil.METADATA_MATCH_FOUND;
			}
			
			return super.canHandleResource(resource);
		}
		
		private static const MEDIA_TYPES_SUPPORTED:Vector.<String> = Vector.<String>([MediaType.AUDIO]);
		private static const MIME_TYPES_SUPPORTED:Vector.<String> = Vector.<String>
			([
				"audio/mp3"
			]);
	}
}