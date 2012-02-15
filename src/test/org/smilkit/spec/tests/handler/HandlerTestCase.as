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
	import flash.display.BitmapData;
	import flash.media.Video;
	
	import flexunit.framework.Assert;
	
	import org.smilkit.SMILKit;
	import org.smilkit.dom.smil.SMILMediaElement;
	import org.smilkit.handler.HTTPVideoHandler;
	import org.smilkit.handler.HandlerMap;
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
			
			SMILKit.defaults();
		}
		
		[After]
		public function tearDown():void
		{
			this._document = null;
			
			HandlerMap.removeHandlers();
		}
		
		[Test(description="Tests finding a default handler")]
		public function findsDefaultHandler():void
		{
			var httpElement:ISMILMediaElement = this._document.getElementById("video_http") as ISMILMediaElement;
			
			Assert.assertNotNull(httpElement);
			
			var httpHandler:Class = HandlerMap.findHandlerClassFor(httpElement);
			
			Assert.assertNotNull(httpHandler);
			
			Assert.assertStrictlyEquals(httpHandler, org.smilkit.handler.HTTPVideoHandler);
		}
		
		[Test(description="Tests that an handler instance can be created for a http video")]
		public function canCreateHandler():void
		{
			var httpElement:ISMILMediaElement = this._document.getElementById("video_http") as ISMILMediaElement;
			
			Assert.assertNotNull(httpElement);
			
			var httpHandler:SMILKitHandler = HandlerMap.createElementHandlerFor(httpElement);
			
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
			
			var httpHandler:SMILKitHandler = HandlerMap.createElementHandlerFor(httpElement);
			
			Assert.assertNotNull(httpHandler);
			
			httpHandler.load();
		}
		
		[Test(description="Tests that a handler can generate a correct bitmap snapshot of the current visible data")]
		public function handlerGeneratesBitmapSnapshot():void
		{
			var httpElement:ISMILMediaElement = this._document.getElementById("video_http") as ISMILMediaElement;
			
			Assert.assertNotNull(httpElement);
			
			var httpHandler:SMILKitHandler = HandlerMap.createElementHandlerFor(httpElement);
			
			Assert.assertNotNull(httpHandler);
			
			httpHandler.load();
			
			var snapshot:BitmapData = httpHandler.bitmapSnapshot;
			
			Assert.assertEquals(httpHandler.innerDisplayObject.width, snapshot.width);
			Assert.assertEquals(httpHandler.innerDisplayObject.height, snapshot.height);
		}
		
		[Test(description="Tests that a handler sets the intrinsic byte size if the param is found")]
		public function intrinsicFileSizeResolvedFromParams():void
		{
			var httpElement:SMILMediaElement = this._document.getElementById("video_http") as SMILMediaElement;
			var httpHandler:SMILKitHandler = HandlerMap.createElementHandlerFor(httpElement);
			Assert.assertEquals(1000, httpElement.bytesTotal);
		}
	}
}