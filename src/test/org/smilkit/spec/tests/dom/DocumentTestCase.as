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
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.parsers.BostonDOMParser;
	import org.smilkit.spec.Fixtures;
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.IElement;
	import org.smilkit.w3c.dom.INode;
	import org.smilkit.w3c.dom.INodeList;

	//import org.smilkit.w3c.dom.INodeList;
	
	public class DocumentTestCase
	{	
		protected var _document:SMILDocument;
	
		public function DocumentTestCase()
		{
			
		}
		
		[Before]
		public function setUp():void
		{
			SMILKit.defaults();
			
			var parser:BostonDOMParser = new BostonDOMParser();
			this._document = (parser.parse(Fixtures.MULTIPLE_CHILDREN_SMIL_XML) as SMILDocument);
		}
		
		[Test(description="Tests the creation of a Document")]
		public function creation():void
		{			
			var document:IDocument = new Document(new DocumentType(null, "smil"));
			
			Assert.assertNotNull(document);
		}
		
		[Test(description="Tests that a document can accept 2 children and the first + last children properties arent invalid")]
		public function acceptsChildren():void
		{
			var document:IDocument = new Document(new DocumentType(null, "smil"));
			Assert.assertNotNull(document);
			
			var el:IElement = document.createElement("body");
			document.appendChild(el);
			
			var el2:IElement = document.createElement("head");
			document.appendChild(el2);
			
			if (!document.hasChildNodes())
			{
				Assert.fail("Document should contain 2 children");
			}
			else
			{
				Assert.assertEquals(document.childNodes.length, 2);
				
				if (document.firstChild == document.lastChild)
				{
					Assert.fail("First child and last child are the same when theres 2 different children in the document");
				}
			}
		}
		
		[Test(description="Tests searching a document by tag name")]
		public function findingElementsByTagName():void
		{
			var document:IDocument = new Document(new DocumentType(null, "smil"));
			Assert.assertNotNull(document);
			
			var el:IElement = document.createElement("body");
			document.appendChild(el);
			
			var el2:IElement = document.createElement("body");
			document.appendChild(el2);
			
			var list:INodeList = document.getElementsByTagName("body");
			Assert.assertNotNull(list);
			Assert.assertEquals(2, list.length);
		}
		
		[Test(description="Tests finding an element on a element that isnt the main document")]
		public function findingAnElementFromANonDocument():void
		{
			var list:INodeList = this._document.getElementsByTagName("metadata");
			
			Assert.assertNotNull(list);
			Assert.assertEquals(3, list.length);
			
			var head:INode = this._document.getElementsByTagName("head").item(0);
			
			var metas:INodeList = (head as Element).getElementsByTagName("metadata");
			
			Assert.assertNotNull(metas);
			Assert.assertEquals(3, metas.length);
		}
	}
}