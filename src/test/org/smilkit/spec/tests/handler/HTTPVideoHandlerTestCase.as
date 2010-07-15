package org.smilkit.spec.tests.handler
{
	import flexunit.framework.Assert;
	
	import org.flexunit.async.Async;
	import org.smilkit.SMILKit;
	import org.smilkit.events.HandlerEvent;
	import org.smilkit.handler.HTTPVideoHandler;
	import org.smilkit.parsers.BostonDOMParser;
	import org.smilkit.spec.Fixtures;
	import org.smilkit.w3c.dom.smil.ISMILDocument;
	import org.smilkit.w3c.dom.smil.ISMILElement;
	import org.smilkit.w3c.dom.smil.ISMILMediaElement;

	public class HTTPVideoHandlerTestCase
	{		
		protected var _document:ISMILDocument;
		protected var _httpElement:ISMILMediaElement;
		protected var _httpVideoHandler:HTTPVideoHandler;
		
		[Before]
		public function setUp():void
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			this._document = (parser.parse(Fixtures.MP4_VIDEO_SMIL_XML) as ISMILDocument);
			
			SMILKit.defaults();
			
			this._httpElement = this._document.getElementById("video_http") as ISMILMediaElement;
			this._httpVideoHandler = (SMILKit.createElementHandlerFor(this._httpElement) as HTTPVideoHandler);
		}
		
		[After]
		public function tearDown():void
		{
			this._document = null;
			
			SMILKit.removeHandlers();
		}
		
		[Test(async,descriptions="Tests resolving a HTTP video")]
		public function ableToResolveVideo():void
		{
			var asyncResolveCheck:Function = Async.asyncHandler(this, this.onHandlerResolved, 5000, this.onHandlerResolveTimeout);
			
			this._httpVideoHandler.addEventListener(HandlerEvent.DURATION_RESOLVED, asyncResolveCheck);
			this._httpVideoHandler.load();
		}
		
		protected function onHandlerResolved(e:HandlerEvent, passThru:Object):void
		{
			// check its the right resolved duration
			Assert.assertEquals(210, e.handler.duration);
			
			// check the dom is still using the defined smil ending
			Assert.assertEquals(10, e.handler.element.dur);
		}
		
		protected function onHandlerResolveTimeout(passThru:Object):void
		{
			Assert.fail("Timeout occured whilst trying to resolve the HTTP video's duration.");
		}
	}
}