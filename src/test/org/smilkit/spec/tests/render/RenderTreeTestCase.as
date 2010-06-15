package org.smilkit.spec.tests.render
{
	import flexunit.framework.Assert;
	
	import org.flexunit.async.Async;
	import org.smilkit.events.ViewportEvent;
	import org.smilkit.render.RenderTree;
	import org.smilkit.time.TimingNode;
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
			var renderTree:RenderTree = this._viewport.renderTree;
			var renderElements:Vector.<TimingNode> = renderTree.elements;
			var elementsNum:int = renderElements.length;
			var resolveTimeElement:TimingNode = renderElements[0];
			Assert.assertEquals(1, elementsNum);
			Assert.assertEquals("video_http", resolveTimeElement.element.id);
	
		}
		
		protected function handleHasElementsTimeOut(passThroughData:Object):void
		{
			Assert.fail( "Timeout reached before viewport refreshed: handleHasElements");
		}
		
		
		[Test(async, description="Tests that the RenderTree has a last change offset")]
		public function hasLastChangeOffSet():void
		{
			var asyncLastChangeOffSetCheck:Function = Async.asyncHandler(this, handleHasLastChangeOffSet, 5000, null, handleHasLastChangeOffSetTimeOut);
			this._viewport.addEventListener(ViewportEvent.REFRESH_COMPLETE, asyncLastChangeOffSetCheck, false, 0, true);
			this._viewport.location = "http://sixty.im/demo.smil";
		}
		
		protected function handleHasLastChangeOffSet(event:ViewportEvent, passThroughData:Object):void
		{
			var renderTree:RenderTree = this._viewport.renderTree;
			Assert.assertEquals(0,renderTree.lastChangeOffset);
		}
		
		protected function handleHasLastChangeOffSetTimeOut(passThroughData:Object):void
		{
			Assert.fail( "Timeout reached before viewport refreshed: hasLastChangeOffSet");
		}
		
		
		[Test(async, description="Tests that the RenderTree has a next change offset")]
		public function hasNextChangeOffSet():void
		{
			var asyncNextOffSetCheck:Function = Async.asyncHandler(this, handleHasNextChangeOffSet, 5000, null, handleHasNextChangeOffSetTimeOut);
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
	}
}