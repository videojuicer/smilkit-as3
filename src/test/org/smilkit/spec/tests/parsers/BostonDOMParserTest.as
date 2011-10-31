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
package org.smilkit.spec.tests.parsers
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import flexunit.framework.Assert;
	
	import org.flexunit.async.Async;
	import org.smilkit.dom.events.MutationEvent;
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.dom.smil.SMILRefElement;
	import org.smilkit.parsers.BostonDOMParser;
	import org.smilkit.parsers.BostonDOMParserEvent;
	import org.smilkit.spec.Fixtures;
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.IElement;
	import org.smilkit.w3c.dom.INodeList;

	public class BostonDOMParserTest
	{		
		
		private var _parser:BostonDOMParser
		
		[Before]
		public function setUp():void
		{
			_parser = new BostonDOMParser();
		}
		
		[After]
		public function tearDown():void
		{
			_parser = null;
		}
		
		[Test(async, description="Tests that the parser can return a document")]
		public function returnsSMILDocument():void
		{
			var document:IDocument = this._parser.parse(Fixtures.BASIC_SMIL_XML) as IDocument;
			
			Assert.assertTrue(document is SMILDocument);
		}
		
		[Test(async, description="Tests that the document can collapse and flatten reference documents correctly")]
		public function referencesAreFlat():void
		{
			var document:IDocument = this._parser.parse(Fixtures.BASIC_REFERENCE_SMIL_XML) as IDocument;
			
			Assert.assertTrue(document is SMILDocument);
			
			var references:INodeList = document.getElementsByTagName("ref");
			
			Assert.assertNotNull(references);
			
			var reference:SMILRefElement = references.item(0) as SMILRefElement;
			
			Assert.assertNotNull(reference);
			
			var async:Function = Async.asyncHandler(this, this.onDOMNodeInserted, 5000, { ref: reference }, this.onDOMNodeInsertedTimeout);
		}
		
		protected function onDOMNodeInserted(e:BostonDOMParserEvent, passThru:Object):void
		{
			var reference:SMILRefElement = passThru["ref"];
			
			Assert.assertNotNull(reference);
			Assert.assertTrue(reference.hasChildNodes());
			
			var el:IElement = reference.ownerDocument.getElementById("video_http");
			
			Assert.assertNotNull(el);
			
			Assert.assertEquals(0, reference.begin.first.resolvedOffset);
		}
		
		protected function onDOMNodeInsertedTimeout(passThru:Object):void
		{
			Assert.fail("Timeout reached whilst waiting for reference parser to complete");
		}
	}
}