package org.smilkit.spec.tests.render
{
	import flash.display.Sprite;
	
	import flexunit.framework.Assert;
	
	import org.flexunit.async.Async;
	import org.smilkit.events.ViewportEvent;
	import org.smilkit.render.DrawingBoard;
	import org.smilkit.render.RenderTree;
	import org.smilkit.time.Heartbeat;
	import org.smilkit.view.Viewport;

	public class DrawingBoardTestClass
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
		
		[Test(async, description="Tests that the DrawBoard has a RenderTree")]
		public function hasRenderTree():void
		{
			var asyncHasRenderTree:Function = Async.asyncHandler(this, handleHasRenderTree, 5000, null, handleHasRenderTreeTimeOut);
			this._viewport.addEventListener(ViewportEvent.REFRESH_COMPLETE, asyncHasRenderTree, false, 0, true);
			this._viewport.location = "http://sixty.im/demo.smil";	
		}
	    
		protected function handleHasRenderTree(event:ViewportEvent, passThroughData:Object):void
		{
			var drawingBoard:DrawingBoard = this._viewport.drawingBoard;
			var renderTree:RenderTree = drawingBoard.renderTree;
			
			Assert.assertStrictlyEquals(this._viewport.renderTree, renderTree);
		}
		
		protected function handleHasRenderTreeTimeOut(passThroughData:Object):void
		{
			Assert.fail( "Timeout reached before viewport refreshed: DrawingBoardTestCase:handleHasRenderTree");
		}
		
		[Test(async, description="Tests that the DrawBoard has a Canvas")]
		public function hasCanvas():void
		{
			var asyncHasCanvas:Function = Async.asyncHandler(this, handleHasCanvas, 5000, null, handleHasCanvasTimeOut);
			this._viewport.addEventListener(ViewportEvent.REFRESH_COMPLETE, asyncHasCanvas, false, 0, true);
			this._viewport.location = "http://sixty.im/demo.smil";	
		}
		
		protected function handleHasCanvas(event:ViewportEvent, passThroughData:Object):void
		{
			var drawingBoard:DrawingBoard = this._viewport.drawingBoard;
			var canvas:Sprite = drawingBoard.canvas;
			Assert.assertTrue(canvas is Sprite);
		}
		
		protected function handleHasCanvasTimeOut(passThroughData:Object):void
		{
			Assert.fail( "Timeout reached before viewport refreshed: DrawingBoardTestCase:handleHasCanvas");
		}
		
		
	}
}