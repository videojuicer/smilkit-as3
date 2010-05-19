package org.smilkit.spec.tests.render
{
	import flexunit.framework.Assert;
	
	import org.flexunit.async.Async;
	import org.smilkit.events.ViewportEvent;
	import org.smilkit.render.RenderTree;
	import org.smilkit.time.ResolvedTimeElement;
	import org.smilkit.view.Viewport;

	public class RenderTreeTestCase
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
		
		[Test(async, description="Tests that the elements collection is populated")]
		public function hasElements():void
		{
			var asyncElementsCheck:Function = Async.asyncHandler(this, handleHasElements, 5000, null, handleHasElementsTimeOut);
			this._viewport.addEventListener(ViewportEvent.REFRESH_COMPLETE, asyncElementsCheck, false, 0, true);
			this._viewport.location = "http://sixty.im/demo.smil";	
		}
		
		protected function handleHasElements(event:ViewportEvent, passThroughData:Object):void
		{
			var renderingTree:RenderTree = this._viewport.renderingTree;
			var renderElements:Vector.<ResolvedTimeElement> = renderingTree.elements;
			var elementsNum:int = renderElements.length;
			var resolveTimeElement:ResolvedTimeElement = renderElements[0];
			Assert.assertEquals(1, elementsNum);
			//Assert.assertEquals("video_http", resolveTimeElement.element.id);
			trace(resolveTimeElement.element.id);
		}
		
		protected function handleHasElementsTimeOut(passThroughData:Object):void
		{
			Assert.fail( "Timeout reached before viewport refreshed: handleHasElements");
		}
		
		
		[Test(async, description="Tests that the RenderTree has a last change offset")]
		public function hasLastChangeOffSet():void
		{
			
		}
		
		[Test(description="Tests that the RenderTree has a next change offset")]
		public function hasNextChangeOffSet():void
		{
			this._viewport.location = "http://smilkit.org/one.smil";
			
		}
		
		[Test(description="Tests that the RenderTree has a TimingGraph")]
		public function hasTimingGraph():void
		{
			this._viewport.location = "http://smilkit.org/one.smil";
			
		}
		
		[Test(description="Tests that the RenderTree has a SMILDocument")]
		public function hasDocument():void
		{
			this._viewport.location = "http://smilkit.org/one.smil";
			
		}
	}
}