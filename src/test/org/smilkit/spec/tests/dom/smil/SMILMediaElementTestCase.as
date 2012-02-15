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
package org.smilkit.spec.tests.dom.smil
{
	import flexunit.framework.Assert;
	
	import org.flexunit.async.Async;
	import org.smilkit.SMILKit;
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.dom.smil.SMILMediaElement;
	import org.smilkit.handler.HandlerMap;
	import org.smilkit.parsers.BostonDOMParser;
	import org.smilkit.spec.Fixtures;
	import org.smilkit.view.Viewport;
	import org.smilkit.w3c.dom.INodeList;
	import org.smilkit.w3c.dom.smil.ISMILDocument;
	import org.smilkit.w3c.dom.smil.ISMILElement;
	import org.smilkit.w3c.dom.smil.ISMILMediaElement;
	
	public class SMILMediaElementTestCase
	{
		protected var _document:ISMILDocument;

		[Before]
		public function setUp():void
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			this._document = (parser.parse(Fixtures.BASIC_LINK_CONTEXT_SMIL_XML) as ISMILDocument);
			SMILKit.defaults();
		}
		
		[After]
		public function tearDown():void
		{
			this._document = null;
			HandlerMap.removeHandlers();
		}

		[Test(description="Tests that a media element in a ref with multiple base tags uses the correct one")]
		public function mediaElementSrcUsesCorrectBase():void
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			var document:SMILDocument = (parser.parse(Fixtures.REF_AND_BASE_TAGS_SMIL_XML) as SMILDocument);

			var videos:INodeList = document.getElementsByTagName("video");
			
			Assert.assertEquals(2, videos.length);
			
			var video1:SMILMediaElement = (document.getElementById("video_1") as SMILMediaElement);
			var video2:SMILMediaElement = (document.getElementById("video_2") as SMILMediaElement);
			
			Assert.assertNotNull(video1);
			Assert.assertNotNull(video2);
			
			Assert.assertEquals("http://hello/1.mp4", video1.src);
			Assert.assertEquals("http://world/2.mp4", video2.src);
		}
		
		[Test(description="Ensures that the link context is correctly recognised on each of the three test elements")]
		public function linkContextsRetrieved():void
		{
			var mediaElement:SMILMediaElement;
			
			// Get the direct wrapper link
			mediaElement = (this._document.getElementById("direct") as SMILMediaElement);
			Assert.assertNotNull(mediaElement.linkContextElement);

			Assert.assertEquals("directlink", mediaElement.linkContextElement.id);
			
			// Get the uptree wrapper link
			mediaElement = (this._document.getElementById("uptree") as SMILMediaElement);
			Assert.assertEquals("uptreelink", mediaElement.linkContextElement.id);
			
			// Get the unwrapped link
			mediaElement = (this._document.getElementById("notwrapped") as SMILMediaElement);
			Assert.assertNull(mediaElement.linkContextElement);
		}
		
		[Test(description="Tests that a SMILMediaElement has its handler replaced when it gets ancestor changes")]
		public function elementChangesAnsectorCorrectly():void
		{
			var element:SMILMediaElement = (this._document.createMediaElement("video") as SMILMediaElement);
			element.src = "http://sixty.im/test.mp4";
			
			Assert.assertNull(element.handler);
			
			this._document.appendChild(element);
			
			Assert.assertNotNull(element.handler);
			
			this._document.removeChild(element);
			
			//Assert.assertNull(element.handler);
		}
		
		[Test(description="Ensures that params may be read from an element containing param tags")]
		public function paramReaderHashCorrect():void
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			var doc:ISMILDocument = (parser.parse(Fixtures.PARAMS_SMIL_XML) as ISMILDocument);
			
			// Group params only
			var e:SMILMediaElement = doc.getElementById("group_params") as SMILMediaElement;
			Assert.assertNotNull(e);
			Assert.assertEquals("foo-group1", e.params.foo);
			Assert.assertEquals("bar-group1", e.params.bar);
			Assert.assertNull(e.params.baz);
			
			// Mixed params
			e = doc.getElementById("mixed_params") as SMILMediaElement;
			Assert.assertNotNull(e);
			Assert.assertEquals("foo-group2", e.params.foo);
			Assert.assertEquals("bar-local", e.params.bar);
			Assert.assertEquals("baz-local", e.params.baz);
			
			// Local only
			e = doc.getElementById("local_params") as SMILMediaElement;
			Assert.assertNotNull(e);
			Assert.assertEquals("foo-local", e.params.foo);
			Assert.assertNull(e.params.bar);
			Assert.assertNull(e.params.baz);
		}
	}
}