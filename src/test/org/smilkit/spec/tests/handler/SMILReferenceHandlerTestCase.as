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
package org.smilkit.spec.tests.handler
{
	import flexunit.framework.Assert;
	
	import org.flexunit.async.Async;
	import org.smilkit.SMILKit;
	import org.smilkit.dom.smil.SMILMediaElement;
	import org.smilkit.dom.smil.SMILRefElement;
	import org.smilkit.events.HandlerEvent;
	import org.smilkit.events.ViewportEvent;
	import org.smilkit.handler.HandlerMap;
	import org.smilkit.handler.RTMPVideoHandler;
	import org.smilkit.handler.SMILKitHandler;
	import org.smilkit.handler.SMILReferenceHandler;
	import org.smilkit.parsers.BostonDOMParser;
	import org.smilkit.spec.Fixtures;
	import org.smilkit.view.extensions.SMILViewport;
	import org.smilkit.w3c.dom.INodeList;
	import org.smilkit.w3c.dom.smil.ISMILDocument;
	import org.smilkit.w3c.dom.smil.ISMILElement;
	import org.smilkit.w3c.dom.smil.ISMILMediaElement;
	
	public class SMILReferenceHandlerTestCase
	{
		protected var _document:ISMILDocument;
		protected var _viewport:SMILViewport;
		
		protected var _rtmpElement:ISMILMediaElement;

		[Before]
		public function setUp():void
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			this._document = (parser.parse(Fixtures.BASIC_REFERENCE_SMIL_XML) as ISMILDocument);
			
			this._viewport = new SMILViewport();
			
			SMILKit.defaults();
		}
		
		[After]
		public function tearDown():void
		{
			this._document = null;
			this._viewport = null;
			HandlerMap.removeHandlers();
		}
		
		[Test(description="Tests to ensure that the reference handler is instantiated against the reference element")]
		public function referenceHandlerSelected():void
		{
			var refElement:ISMILMediaElement = this._document.getElementById("reference_tag") as ISMILMediaElement;
			Assert.assertNotNull(refElement);
			
			var handler:Class = HandlerMap.findHandlerClassFor(refElement);
			Assert.assertNotNull(handler);			
			Assert.assertStrictlyEquals(handler, org.smilkit.handler.SMILReferenceHandler);
		}
		
		[Test(async,description="Ensures that the contents of the external document are added to the document on a successful load")]
		public function documentContentInjectedAfterLoad():void
		{
			this._viewport.location = "data:text/plain;charset=utf-8,"+Fixtures.BASIC_REFERENCE_SMIL_XML;
		
			// Wait for the viewport to signal ready
			var asyncViewportReadyHandler:Function = Async.asyncHandler(
				this,
				this.async_documentContentInjectedAfterLoad_viewportRefreshComplete_viewportReady,
				25000,
				this.async_documentContentInjectedAfterLoad_viewportRefreshComplete_viewportWaitTimeout
			);
			this._viewport.addEventListener(ViewportEvent.READY, asyncViewportReadyHandler)
			// Play the viewport
			this._viewport.resume();
		}

				protected function async_documentContentInjectedAfterLoad_viewportRefreshComplete_viewportReady(e:ViewportEvent, passthru:Object):void
				{
					// Assert that the ref tag contains at least one video tag
					var document:ISMILDocument = this._viewport.document;
					Assert.assertNotNull(document);
					
					var refElement:SMILRefElement = document.getElementById("reference_tag") as SMILRefElement;
					
					Assert.assertNotNull(refElement);
					
					var videoChildren:INodeList = refElement.getElementsByTagName("video");
					
					Assert.assertEquals(0, videoChildren.length);
					
					videoChildren = (refElement.handler as SMILReferenceHandler).nestedViewport.document.getElementsByTagName("video");
					
					Assert.assertEquals(1, videoChildren.length);
				}
				protected function async_documentContentInjectedAfterLoad_viewportRefreshComplete_viewportWaitTimeout(passthru:Object):void
				{
					Assert.fail("Timed out waiting for viewport to signal ready");
				}
		
		[Test(async,description="Ensures that the handler's content is invalidated when the handler is removed from the rendertree")]
		public function invalidatedWhenRemovedFromRenderTree():void
		{
			this._viewport.location = "data:text/plain;charset=utf-8,"+Fixtures.REFERENCE_IN_SEQUENCE_SMIL_XML;
			
			var asyncViewportRefreshHandler:Function = Async.asyncHandler(
				this, 
				this.async_invalidatedWhenRemovedFromRenderTree_viewportRefreshCompleted, 
				5000, 
				this.async_invalidatedWhenRemovedFromRenderTree_viewportRefreshTimeout
			);
			this._viewport.addEventListener(ViewportEvent.REFRESH_COMPLETE, asyncViewportRefreshHandler);
			this._viewport.refresh();
		}
			protected function async_invalidatedWhenRemovedFromRenderTree_viewportRefreshCompleted(e:ViewportEvent, passthru:Object):void
			{
				// Resume and wait for ready
				var asyncViewportReadyHandler:Function = Async.asyncHandler(
					this,
					this.async_invalidatedWhenRemovedFromRenderTree_viewportRefreshCompleted_viewportReady,
					10000,
					this.async_invalidatedWhenRemovedFromRenderTree_viewportRefreshCompleted_viewportReadyTimeout
				);
				this._viewport.addEventListener(ViewportEvent.PLAYBACK_OFFSET_CHANGED, asyncViewportReadyHandler)
				// Play the viewport
				this._viewport.resume();
			}
				// On ready, seek to a million bajillion and assert that the element was invalidated
				protected function async_invalidatedWhenRemovedFromRenderTree_viewportRefreshCompleted_viewportReady(e:ViewportEvent, passthru:Object):void
				{
					// get element and attached handler
					var handler:SMILReferenceHandler = ((this._viewport.document.getElementById("reference_tag") as SMILMediaElement).handler as SMILReferenceHandler);
					
					Assert.assertNotNull(handler);
					
					//Assert.assertTrue(handler.contentValid);
					this._viewport.seek(15*60*1000);
					this._viewport.commitSeek();
					Assert.assertFalse(handler.contentValid);
				}
				
				protected function async_invalidatedWhenRemovedFromRenderTree_viewportRefreshCompleted_viewportReadyTimeout(passthru:Object):void
				{
					Assert.fail("Timed out waiting for viewport to get ready to rumble");
				}
			protected function async_invalidatedWhenRemovedFromRenderTree_viewportRefreshTimeout(passthru:Object):void
			{
				Assert.fail("Timed out waiting for viewport to goddamn refresh");
			}
		
		[Test(async,description="Ensures that the handler's content is invalidated when the viewport is paused")]
		public function invalidatedWhenViewportPaused():void
		{
			this._viewport.location = "data:text/plain;charset=utf-8,"+Fixtures.BASIC_REFERENCE_SMIL_XML;
			
			var asyncViewportRefreshHandler:Function = Async.asyncHandler(
				this, 
				this.async_invalidatedWhenViewportPaused_viewportRefreshCompleted, 
				15000, 
				this.async_invalidatedWhenViewportPaused_viewportRefreshTimeout
			);
			this._viewport.addEventListener(ViewportEvent.REFRESH_COMPLETE, asyncViewportRefreshHandler);
			this._viewport.refresh();
		}
			protected function async_invalidatedWhenViewportPaused_viewportRefreshCompleted(e:ViewportEvent, passthru:Object):void
			{
				var asyncViewportReadyHandler:Function = Async.asyncHandler(
					this,
					this.async_invalidatedWhenViewportPaused_viewportRefreshCompleted_viewportReady,
					15000,
					this.async_invalidatedWhenViewportPaused_viewportRefreshCompleted_viewportReadyTimeout
				);
				this._viewport.addEventListener(ViewportEvent.READY, asyncViewportReadyHandler)
				// Play the viewport
				this._viewport.resume();
			}
				protected function async_invalidatedWhenViewportPaused_viewportRefreshCompleted_viewportReady(e:ViewportEvent, passthru:Object):void
				{
					var handler:SMILReferenceHandler = ((this._viewport.document.getElementById("reference_tag") as SMILMediaElement).handler as SMILReferenceHandler);
					Assert.assertNotNull(handler);
					
					Assert.assertTrue(handler.contentValid);
					this._viewport.pause();
					this._viewport.resume();
					
					// this will take a few seconds
					//Assert.assertTrue(handler.contentValid);
				}
				protected function async_invalidatedWhenViewportPaused_viewportRefreshCompleted_viewportReadyTimeout(passthru:Object):void
				{
					Assert.fail("timed out waiting for viewport to get ready, eddie");
				}
			protected function async_invalidatedWhenViewportPaused_viewportRefreshTimeout(passthru:Object):void
			{
				Assert.fail("Timed out waiting for viewport to refresh");
			}
	}
}