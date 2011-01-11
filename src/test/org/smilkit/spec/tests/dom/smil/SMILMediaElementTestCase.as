package org.smilkit.spec.tests.dom.smil
{
	import flexunit.framework.Assert;
	
	import org.flexunit.async.Async;
	import org.smilkit.SMILKit;
	import org.smilkit.view.Viewport;
	import org.smilkit.parsers.BostonDOMParser;
	import org.smilkit.spec.Fixtures;
	import org.smilkit.w3c.dom.smil.ISMILDocument;
	import org.smilkit.w3c.dom.smil.ISMILElement;
	import org.smilkit.w3c.dom.smil.ISMILMediaElement;
	import org.smilkit.dom.smil.SMILMediaElement;
	import org.smilkit.w3c.dom.INodeList;
	
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