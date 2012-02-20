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
package org.smilkit.spec.tests.dom
{
	import flexunit.framework.Assert;
	
	import org.smilkit.SMILKit;
	import org.smilkit.dom.Document;
	import org.smilkit.dom.DocumentType;
	import org.smilkit.dom.Element;
	import org.smilkit.dom.smil.ElementTimeContainer;
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.parsers.BostonDOMParser;
	import org.smilkit.spec.Fixtures;
	import org.smilkit.view.extensions.SMILViewport;
	import org.smilkit.dom.DOMException;
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.IElement;
	import org.smilkit.w3c.dom.INodeList;
	import org.smilkit.w3c.dom.smil.ISMILDocument;
	
	public class ElementTimeDescendantNodeListTestCase
	{
		private var _document:SMILDocument;
		
		[Before]
		public function setUp():void
		{
			SMILKit.defaults();
			
			var parser:BostonDOMParser = new BostonDOMParser();
			this._document = (parser.parse(Fixtures.TIME_CHILDREN_SMIL_XML) as SMILDocument);
		}
		
		[Test(description="Tests that a ElementTimeDescendantNodeList returns the correct number of children")]
		public function timeDescendantListReturnsTheCorrectChildren():void
		{
			var list:INodeList = this._document.timeDescendants;
			
			Assert.assertEquals(1, list.length);
			
			var body:ElementTimeContainer = (this._document.getElementsByTagName("body").item(0) as ElementTimeContainer);
		
			Assert.assertEquals(4, body.childNodes.length);
			Assert.assertEquals(3, body.timeDescendants.length);
		}
		
		[Test(description="Tests that a ElementTimeDescendantNodeList returns the correct children when mixed in with non time container elements")]
		public function timeDescendantListIgnoresFindsFirstTimeContainer():void
		{
			var content:ElementTimeContainer = (this._document.getElementById("content") as ElementTimeContainer);
			
			Assert.assertEquals(3, content.timeChildren.length);
			Assert.assertEquals(1, content.timeDescendants.length);
			
			Assert.assertEquals("body", content.timeDescendants.item(0).nodeName);
		}
	}
}