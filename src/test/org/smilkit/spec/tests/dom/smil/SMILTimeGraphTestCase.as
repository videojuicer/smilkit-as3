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
	
	import mx.utils.object_proxy;
	
	import org.flexunit.async.Async;
	import org.smilkit.SMILKit;
	import org.smilkit.dom.smil.ElementSequentialTimeContainer;
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.dom.smil.time.SMILTimeInstance;
	import org.smilkit.events.ViewportEvent;
	import org.smilkit.parsers.BostonDOMParser;
	import org.smilkit.spec.Fixtures;
	import org.smilkit.view.extensions.SMILViewport;
	import org.smilkit.w3c.dom.smil.ISMILDocument;

	public class SMILTimeGraphTestCase
	{		
		protected var _document:SMILDocument;
		
		[Before]
		public function setUp():void
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			
			this._document = (parser.parse(Fixtures.BASIC_SMIL_XML) as SMILDocument);
		}
		
		[After]
		public function tearDown():void
		{
			this._document = null;
		}
		
		[Test(description="Tests that the elements collection is populated")]
		public function hasElementsInTheTree():void
		{
			Assert.assertEquals(2, this._document.timeGraph.elements.length);
			
			Assert.assertEquals(1, this._document.timeGraph.mediaElements.length);
			
			Assert.assertEquals("body", this._document.timeGraph.elements[0].element.id);
			Assert.assertEquals("content", this._document.timeGraph.elements[1].element.id);
			
			Assert.assertEquals("content", this._document.timeGraph.mediaElements[0].element.id);
		}
	}
}