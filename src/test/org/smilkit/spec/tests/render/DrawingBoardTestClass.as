/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version 1.1
 * (the "License"); you may not use this file except in compliance with the
 * License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 *
 * The Original Code is the SMILKit library.
 *
 * The Initial Developer of the Original Code is
 * Videojuicer Ltd. (UK Registered Company Number: 05816253).
 * Portions created by the Initial Developer are Copyright (C) 2010
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 * 	Dan Glegg
 * 	Adam Livesley
 *
 * ***** END LICENSE BLOCK ***** */
package org.smilkit.spec.tests.render
{
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import flexunit.framework.Assert;
	
	import org.flexunit.async.Async;
	import org.smilkit.events.ViewportEvent;
	import org.smilkit.render.DrawingBoard;
	import org.smilkit.render.HandlerController;
	import org.smilkit.spec.Fixtures;
	import org.smilkit.view.extensions.SMILViewport;

	public class DrawingBoardTestClass
	{		
		protected var _viewport:SMILViewport;
		
		[Before]
		public function setUp():void
		{
			this._viewport = new SMILViewport();
		}
		
		[After]
		public function tearDown():void
		{
			this._viewport = null;
		}
		
		[Test(async, description="Tests that the DrawBoard has a RenderTree")]
		public function hasRenderTree():void
		{
			var asyncHasRenderTree:Function = Async.asyncHandler(this, handleHasRenderTree, 10000, null, handleHasRenderTreeTimeOut);
			this._viewport.addEventListener(ViewportEvent.REFRESH_COMPLETE, asyncHasRenderTree, false, 0, true);
			this._viewport.location = "data:text/plain;charset=utf-8,"+Fixtures.BASIC_SMIL_XML;
		}
	    
		protected function handleHasRenderTree(event:ViewportEvent, passThroughData:Object):void
		{
			var drawingBoard:DrawingBoard = this._viewport.drawingBoard;
			var renderTree:HandlerController = drawingBoard.renderTree;
			
			Assert.assertStrictlyEquals(this._viewport.renderTree, renderTree);
		}
		
		protected function handleHasRenderTreeTimeOut(passThroughData:Object):void
		{
			Assert.fail( "Timeout reached before viewport refreshed: DrawingBoardTestCase:handleHasRenderTree");
		}
		
		[Test(async, description="Tests that the DrawBoard has a Canvas")]
		public function hasCanvas():void
		{
			var asyncHasCanvas:Function = Async.asyncHandler(this, handleHasCanvas, 10000, null, handleHasCanvasTimeOut);
			this._viewport.addEventListener(ViewportEvent.REFRESH_COMPLETE, asyncHasCanvas, false, 0, true);
			this._viewport.location = "data:text/plain;charset=utf-8,"+Fixtures.BASIC_SMIL_XML;
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
		
		[Test(description="DrawingBoard resizes when triggered with boundingRect")]
		public function resizesWhenBoundingRectSets():void
		{
			Assert.assertEquals(0, this._viewport.drawingBoard.canvas.width);
			Assert.assertEquals(0, this._viewport.drawingBoard.canvas.height);
			
			Assert.assertEquals(0, this._viewport.drawingBoard.width);
			Assert.assertEquals(0, this._viewport.drawingBoard.height);
			
			Assert.assertEquals(0, this._viewport.width);
			Assert.assertEquals(0, this._viewport.height);
			
			var rect:Rectangle = new Rectangle(0, 0, 1000, 1000);
			
			this._viewport.boundingRect = rect;

			Assert.assertEquals(1000, this._viewport.drawingBoard.canvas.width);
			Assert.assertEquals(1000, this._viewport.drawingBoard.canvas.height);
			
			Assert.assertEquals(1000, this._viewport.drawingBoard.width);
			Assert.assertEquals(1000, this._viewport.drawingBoard.height);
			
			Assert.assertEquals(1000, this._viewport.width);
			Assert.assertEquals(1000, this._viewport.height);
		}
	}
}