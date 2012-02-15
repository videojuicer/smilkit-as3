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
	import org.smilkit.events.HandlerEvent;
	import org.smilkit.handler.HandlerMap;
	import org.smilkit.handler.SMILReferenceHandler;
	import org.smilkit.parsers.BostonDOMParser;
	import org.smilkit.spec.Fixtures;
	import org.smilkit.w3c.dom.smil.ISMILDocument;
	import org.smilkit.w3c.dom.smil.ISMILElement;
	import org.smilkit.w3c.dom.smil.ISMILMediaElement;
	
	public class RTMPVideoHandlerTestCase
	{
		protected var _document:ISMILDocument;
		protected var _rtmpElement:ISMILMediaElement;
		protected var _rtmpVideoHandler:SMILReferenceHandler;

		[Before]
		public function setUp():void
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			this._document = (parser.parse(Fixtures.MP4_VIDEO_SMIL_XML) as ISMILDocument);
			
			SMILKit.defaults();
			
			this._rtmpElement = this._document.getElementById("video_rtmp") as ISMILMediaElement;
			this._rtmpVideoHandler = (HandlerMap.createElementHandlerFor(this._rtmpElement) as SMILReferenceHandler);
		}
		
		[After]
		public function tearDown():void
		{
			this._document = null;
			
			HandlerMap.removeHandlers();
		}
		
		[Test(async,descriptions="Tests resolving an RTMP video")]
		public function ableToResolveVideo():void
		{
			var asyncResolveCheck:Function = Async.asyncHandler(this, this.onHandlerResolved, 25000, this.onHandlerResolveTimeout);
			
			this._rtmpVideoHandler.addEventListener(HandlerEvent.DURATION_RESOLVED, asyncResolveCheck);
			this._rtmpVideoHandler.load();
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
			Assert.fail("Timeout occured whilst trying to resolve the RTMP video's duration.");
		}
	}
}