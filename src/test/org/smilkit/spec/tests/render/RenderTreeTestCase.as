package org.smilkit.spec.tests.render
{
	import flexunit.framework.Assert;
	
	import org.flexunit.async.Async;
	import org.smilkit.SMILKit;
	import org.smilkit.events.ViewportEvent;
	import org.smilkit.render.RenderTree;
	import org.smilkit.spec.Fixtures;
	import org.smilkit.dom.smil.time.SMILTimeInstance;
	import org.smilkit.view.Viewport;

	public class RenderTreeTestCase
	{
		protected var _viewport:Viewport;
		
		[Before]
		public function setUp():void
		{
			this._viewport = new Viewport();
			
			SMILKit.defaults();
		}
		
		[After]
		public function tearDown():void
		{
			this._viewport = null;
		}
		
		[Test(async, description="Tests that the elements collection is populated")]
		public function hasElements():void
		{
			var asyncElementsCheck:Function = Async.asyncHandler(this, this.handleHasElements, 2000, null, this.handleHasElementsTimeOut);
			
			this._viewport.addEventListener(ViewportEvent.REFRESH_COMPLETE, asyncElementsCheck, false, 0, true);
			this._viewport.location = "http://sixty.im/demo.smil";	
		}		
			protected function handleHasElements(e:ViewportEvent, passThru:Object):void
			{
				var renderTree:RenderTree = this._viewport.renderTree;
				var renderElements:Vector.<SMILTimeInstance> = renderTree.elements;
				var elementsNum:int = renderElements.length;
				
				Assert.assertEquals(1, elementsNum);
				
				var resolveTimeElement:SMILTimeInstance = renderElements[0];

				Assert.assertEquals("video_http", resolveTimeElement.element.id);
			}
			protected function handleHasElementsTimeOut(passThroughData:Object):void
			{
				Assert.fail( "Timeout reached before viewport refreshed: handleHasElements");
			}
		
		[Test(async, description="Tests that the RenderTree has a last change offset")]
		public function hasLastChangeOffSet():void
		{
			var asyncLastChangeOffSetCheck:Function = Async.asyncHandler(this, this.handleHasLastChangeOffSet, 5000, null, this.handleHasLastChangeOffSetTimeOut);
			
			this._viewport.addEventListener(ViewportEvent.REFRESH_COMPLETE, asyncLastChangeOffSetCheck, false, 0, true);
			this._viewport.location = "http://sixty.im/demo.smil";
		}
		
		protected function handleHasLastChangeOffSet(event:ViewportEvent, passThroughData:Object):void
		{
			var renderTree:RenderTree = this._viewport.renderTree;
			
			Assert.assertEquals(0, renderTree.lastChangeOffset);
		}
		
		protected function handleHasLastChangeOffSetTimeOut(passThroughData:Object):void
		{
			Assert.fail( "Timeout reached before viewport refreshed: hasLastChangeOffSet");
		}
		
		[Test(async, description="Tests that the RenderTree has a next change offset")]
		public function hasNextChangeOffSet():void
		{
			var asyncNextOffSetCheck:Function = Async.asyncHandler(this, this.handleHasNextChangeOffSet, 5000, null, this.handleHasNextChangeOffSetTimeOut);
			
			this._viewport.addEventListener(ViewportEvent.REFRESH_COMPLETE, asyncNextOffSetCheck, false, 0, true);
			this._viewport.location = "http://sixty.im/demo.smil";
		}
		
		protected function handleHasNextChangeOffSet(event:ViewportEvent, passThroughData:Object):void
		{
			var renderTree:RenderTree = this._viewport.renderTree;
			
			Assert.assertEquals(-1,renderTree.nextChangeOffset);
		}
		
		protected function handleHasNextChangeOffSetTimeOut(passThroughData:Object):void
		{
			Assert.fail( "Timeout reached before viewport refreshed: hasNextChangeOffSet");
		}
		
		[Test(async, description="Tests that elements with a render state are kept off the render tree")]
		public function elementsWithFailingTestsHide():void
		{
			var asyncElementsCheck:Function = Async.asyncHandler(this, this.elementsWithFailingTestsHide_refreshed, 2000, null, this.elementsWithFailingTestsHide_refreshedTimeout);
			
			this._viewport.addEventListener(ViewportEvent.REFRESH_COMPLETE, asyncElementsCheck, false, 0, true);
			this._viewport.location = "data:text/plain;charset=utf-8,"+Fixtures.ELEMENT_BASIC_TEST_SMIL_XML;
		}		
		protected function elementsWithFailingTestsHide_refreshed(e:ViewportEvent, passThru:Object):void
		{
			Assert.assertEquals(3, this._viewport.renderTree.elements.length);
			Assert.assertEquals(13, this._viewport.document.timeGraph.mediaElements.length);
		}
		protected function elementsWithFailingTestsHide_refreshedTimeout(passThroughData:Object):void
		{
			Assert.fail( "Timeout reached before viewport refreshed: elementsWithFailingTestsHide");
		}
	}
}