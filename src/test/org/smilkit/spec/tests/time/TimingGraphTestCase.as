package org.smilkit.spec.tests.time
{
	import flexunit.framework.Assert;
	
	import org.flexunit.async.Async;
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.events.ViewportEvent;
	import org.smilkit.time.ResolvedTimeElement;
	import org.smilkit.time.TimingGraph;
	import org.smilkit.view.Viewport;
	import org.smilkit.w3c.dom.smil.ISMILDocument;

	public class TimingGraphTestCase
	{		
		protected var _viewport:Viewport;
		
		[Before]
		public function setUp():void
		{
			this._viewport = new Viewport();
		}
		
		[After]
		public function tearDown():void
		{
			this._viewport = null;
		}
		
		/**
		 * For testing the TimingGraph has a valid document reference 
		 */		
		[Test(async, description="Tests that the TimingGraph has a reference to the document is populated")]
		public function hasDocument():void
		{
			var asyncDocumentCheck:Function = Async.asyncHandler(this, handleHasDocument, 5000, null, handleHasDocumentTimeOut);
			this._viewport.addEventListener(ViewportEvent.REFRESH_COMPLETE, asyncDocumentCheck, false, 0, true);
			this._viewport.location = "http://sixty.im/demo.smil";	
		}

		protected function handleHasDocument(event:ViewportEvent, passThroughData:Object):void
		{
			var timingGraph:TimingGraph = this._viewport.timingGraph;
			var document:ISMILDocument = timingGraph.document; 
			
			// check document.timeChildren
			Assert.assertEquals(3, document.timeChildren.length);
			// check document.begin
			Assert.assertEquals(1, document.begin.length);
			// check document.end
			Assert.assertEquals(1, document.end.length);
		}
		
		protected function handleHasDocumentTimeOut(passThroughData:Object):void
		{
			Assert.fail( "Timeout reached before viewport refreshed: TimingGraphTestCase:handleHasDocument");
		}
		
		[Test(async, description="Tests that the elements collection is populated")]
		public function hasElements():void
		{
			var asyncElementsCheck:Function = Async.asyncHandler(this, handleHasElements, 5000, null, handleHasElementsTimeOut);
			this._viewport.addEventListener(ViewportEvent.REFRESH_COMPLETE, asyncElementsCheck, false, 0, true);
			this._viewport.location = "http://sixty.im/demo.smil";	
		}
		
		protected function handleHasElements(event:ViewportEvent, passThroughData:Object):void
		{
			var timingGraph:TimingGraph = this._viewport.timingGraph;
			var elements:Vector.<ResolvedTimeElement> = timingGraph.elements;
			var elementsNum:int = elements.length;
			var resolveTimeElement:ResolvedTimeElement = elements[0];
			Assert.assertEquals(1, elementsNum);
			Assert.assertEquals("video_http", resolveTimeElement.element.id);	
		}
		
		protected function handleHasElementsTimeOut(passThroughData:Object):void
		{
			Assert.fail( "Timeout reached before viewport refreshed: handleHasElements");
		}
		
		
		
		
		
		
	}
}