package org.smilkit.spec.tests
{
	import flexunit.framework.Assert;
	
	import org.smilkit.SMILKit;
	import org.smilkit.handler.HTTPVideoHandler;
	import org.smilkit.handler.SMILKitHandler;
	import org.smilkit.parsers.BostonDOMParser;
	import org.smilkit.spec.Fixtures;
	import org.smilkit.w3c.dom.smil.ISMILDocument;
	import org.smilkit.w3c.dom.smil.ISMILMediaElement;

	public class HandlerTestCase
	{		
		protected var _document:ISMILDocument;
		
		[Before]
		public function setUp():void
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			this._document = (parser.parse(Fixtures.MP4_VIDEO_SMIL_XML) as ISMILDocument);
			
			SMILKit.defaultHandlers();
		}
		
		[After]
		public function tearDown():void
		{
			this._document = null;
			
			SMILKit.removeHandlers();
		}
		
		[Test(description="Tests finding a default handler")]
		public function findsDefaultHandler():void
		{
			var httpElement:ISMILMediaElement = this._document.getElementById("video_http") as ISMILMediaElement;
			
			Assert.assertNotNull(httpElement);
			
			var httpHandler:Class = SMILKit.findHandlerClassFor(httpElement);
			
			Assert.assertNotNull(httpHandler);
			
			Assert.assertStrictlyEquals(httpHandler, org.smilkit.handler.HTTPVideoHandler);
		}
		
		[Test(description="Tests that an handler instance can be created for a http video")]
		public function canCreateHandler():void
		{
			var httpElement:ISMILMediaElement = this._document.getElementById("video_http") as ISMILMediaElement;
			
			Assert.assertNotNull(httpElement);
			
			var httpHandler:SMILKitHandler = SMILKit.createElementHandlerFor(httpElement);
			
			Assert.assertNotNull(httpHandler);
			
			if (!httpHandler is HTTPVideoHandler)
			{
				Assert.fail("Created handler is not type of HTTPVideoHandler.");
			}
		}
		
		[Test(description="Tests loading a video asset")]
		public function videoHandlerLoads():void
		{
			var httpElement:ISMILMediaElement = this._document.getElementById("video_http") as ISMILMediaElement;
			
			Assert.assertNotNull(httpElement);
			
			var httpHandler:SMILKitHandler = SMILKit.createElementHandlerFor(httpElement);
			
			Assert.assertNotNull(httpHandler);
			
			httpHandler.load();
		}
	}
}