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
	
	import org.smilkit.dom.smil.ElementLoadableContainer;
	import org.smilkit.dom.smil.FileSize;
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.dom.smil.expressions.SMILDocumentVariables;
	import org.smilkit.w3c.dom.INode;
	import org.smilkit.w3c.dom.IElement;
	import org.smilkit.parsers.BostonDOMParser;
	import org.smilkit.spec.Fixtures;

	public class ElementLoadableContainerTestCase
	{
		protected var _document:SMILDocument;
		protected var _body:ElementLoadableContainer;
		protected var _linkWrappedVideo:ElementLoadableContainer;
		protected var _deepWrappedVideo:ElementLoadableContainer;
		protected var _unwrappedVideo:ElementLoadableContainer;
		
		[Before]
		public function setup():void
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			this._document = (parser.parse(Fixtures.BASIC_LINK_CONTEXT_SMIL_XML) as SMILDocument);
			this._body = this._document.getElementsByTagName("body").item(0) as ElementLoadableContainer;
			this._linkWrappedVideo = this._document.getElementById("direct") as ElementLoadableContainer;
			this._deepWrappedVideo = this._document.getElementById("uptree") as ElementLoadableContainer;
			this._unwrappedVideo = this._document.getElementById("notwrapped") as ElementLoadableContainer;
		}
		
		[After]
		public function teardown():void
		{
			
		}
		
		[Test(description="Locates the parent loadable container")]
		public function parentLoadableContainerLocated():void
		{
			Assert.assertNull(this._body.parentLoadableContainer);
			Assert.assertEquals(this._body, this._linkWrappedVideo.parentLoadableContainer);
		}
		
		[Test(description="Bubbles file size changes to the parent load container")]
		public function loadPropertyChangesBubbled():void
		{
			this._linkWrappedVideo.intrinsicBytesLoaded = 0;
			this._linkWrappedVideo.intrinsicBytesTotal = 0;
			this._deepWrappedVideo.intrinsicBytesLoaded = 0;
			this._deepWrappedVideo.intrinsicBytesTotal = 0;
			this._unwrappedVideo.intrinsicBytesLoaded = 5000;
			this._unwrappedVideo.intrinsicBytesTotal = 10000;
			
			Assert.assertEquals(5000, this._unwrappedVideo.bytesLoaded);
			Assert.assertEquals(10000, this._unwrappedVideo.bytesTotal);
			Assert.assertEquals(5000, this._body.bytesLoaded);
			Assert.assertEquals(10000, this._body.bytesTotal);
			Assert.assertEquals(5000, this._document.loadables.bytesLoaded);
			Assert.assertEquals(10000, this._document.loadables.bytesTotal);
			
			// Set unresolved on the deep-wrapped video
			this._deepWrappedVideo.intrinsicBytesLoaded = FileSize.UNRESOLVED;
			Assert.assertEquals(FileSize.UNRESOLVED, this._body.bytesLoaded);
			Assert.assertEquals(10000, this._body.bytesTotal);
			this._deepWrappedVideo.intrinsicBytesTotal = FileSize.UNRESOLVED;
			Assert.assertEquals(FileSize.UNRESOLVED, this._body.bytesLoaded);
			Assert.assertEquals(FileSize.UNRESOLVED, this._body.bytesTotal);
			Assert.assertEquals(5000, this._unwrappedVideo.bytesLoaded);
			Assert.assertEquals(10000, this._unwrappedVideo.bytesTotal);
			
			// Resolve it
			this._deepWrappedVideo.intrinsicBytesLoaded = 5000;
			Assert.assertEquals(10000, this._body.bytesLoaded);
			Assert.assertEquals(FileSize.UNRESOLVED, this._body.bytesTotal);
			this._deepWrappedVideo.intrinsicBytesTotal = 10000;
			Assert.assertEquals(10000, this._body.bytesLoaded);
			Assert.assertEquals(20000, this._body.bytesTotal);
			Assert.assertEquals(5000, this._unwrappedVideo.bytesLoaded);
			Assert.assertEquals(10000, this._unwrappedVideo.bytesTotal);
			
			// Now try an intrinsic set on the body
			this._body.intrinsicBytesLoaded = FileSize.UNRESOLVED;
			Assert.assertEquals(FileSize.UNRESOLVED, this._body.bytesLoaded);
			Assert.assertEquals(FileSize.UNRESOLVED, this._document.loadables.bytesLoaded);
			this._body.intrinsicBytesTotal = FileSize.UNRESOLVED;
			Assert.assertEquals(FileSize.UNRESOLVED, this._body.bytesTotal);
			Assert.assertEquals(FileSize.UNRESOLVED, this._document.loadables.bytesTotal);
			
			this._body.intrinsicBytesLoaded = 30;
			Assert.assertEquals(10030, this._body.bytesLoaded);
			Assert.assertEquals(10030, this._document.loadables.bytesLoaded);
			
			this._body.intrinsicBytesTotal = 40;
			Assert.assertEquals(20040, this._body.bytesTotal);
			Assert.assertEquals(20040, this._document.loadables.bytesTotal);
		}
	}
}