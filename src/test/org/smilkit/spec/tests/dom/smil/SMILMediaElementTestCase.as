package org.smilkit.spec.tests.dom.smil
{
	import flexunit.framework.Assert;
	
	import org.flexunit.async.Async;
	import org.smilkit.SMILKit;
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.dom.smil.SMILMediaElement;
	import org.smilkit.parsers.BostonDOMParser;
	import org.smilkit.spec.Fixtures;
	import org.smilkit.view.Viewport;
	import org.smilkit.w3c.dom.INodeList;
	import org.smilkit.w3c.dom.smil.ISMILDocument;
	import org.smilkit.w3c.dom.smil.ISMILElement;
	import org.smilkit.w3c.dom.smil.ISMILMediaElement;
	
	public class SMILMediaElementTestCase
	{
		protected var _document:ISMILDocument;

		[Before]
		public function setUp():void
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			this._document = (parser.parse(Fixtures.BASIC_LINK_CONTEXT_SMIL_XML) as ISMILDocument);
			SMILKit.defaults();
		}
		
		[After]
		public function tearDown():void
		{
			this._document = null;
			SMILKit.removeHandlers();
		}

		[Test(description="Tests that a media element in a ref with multiple base tags uses the correct one")]
		public function mediaElementSrcUsesCorrectBase():void
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			var document:SMILDocument = (parser.parse(Fixtures.REF_AND_BASE_TAGS_SMIL_XML) as SMILDocument);

			var videos:INodeList = document.getElementsByTagName("video");
			
			Assert.assertEquals(2, videos.length);
			
			var video1:SMILMediaElement = (document.getElementById("video_1") as SMILMediaElement);
			var video2:SMILMediaElement = (document.getElementById("video_2") as SMILMediaElement);
			
			Assert.assertNotNull(video1);
			Assert.assertNotNull(video2);
			
			Assert.assertEquals("http://hello/1.mp4", video1.src);
			Assert.assertEquals("http://world/2.mp4", video2.src);
		}
		
		[Test(description="Ensures that the link context is correctly recognised on each of the three test elements")]
		public function linkContextsRetrieved():void
		{
			var mediaElement:SMILMediaElement;
			
			// Get the direct wrapper link
			mediaElement = (this._document.getElementById("direct") as SMILMediaElement);
			Assert.assertNotNull(mediaElement.linkContextElement);

			Assert.assertEquals("directlink", mediaElement.linkContextElement.id);
			
			// Get the uptree wrapper link
			mediaElement = (this._document.getElementById("uptree") as SMILMediaElement);
			Assert.assertEquals("uptreelink", mediaElement.linkContextElement.id);
			
			// Get the unwrapped link
			mediaElement = (this._document.getElementById("notwrapped") as SMILMediaElement);
			Assert.assertNull(mediaElement.linkContextElement);
		}
	}
}