package org.smilkit.spec.tests.dom
{
	import flexunit.framework.Assert;
	
	import org.smilkit.SMILKit;
	import org.smilkit.dom.Document;
	import org.smilkit.dom.DocumentType;
	import org.smilkit.dom.Element;
	import org.smilkit.parsers.BostonDOMParser;
	import org.smilkit.spec.Fixtures;
	import org.smilkit.view.Viewport;
	import org.smilkit.dom.DOMException;
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.IElement;
	import org.smilkit.w3c.dom.smil.ISMILDocument;
	
	public class ElementTestCase
	{
		private var _document:IDocument;
		private var _multiDocument:ISMILDocument;
		
		public function ElementTestCase()
		{
			this._document = new Document(new DocumentType(null, "smil"));
		}
		
		[Before]
		public function setUp():void
		{
			SMILKit.defaults();
			
			var parser:BostonDOMParser = new BostonDOMParser();
			this._multiDocument = (parser.parse(Fixtures.MULTIPLE_CHILDREN_SMIL_XML) as ISMILDocument);
		}
		
		[Test(description="Tests the creation of an Element on a Document.")]
		public function creation():void
		{
			var el:IElement = this._document.createElement("body");
			Assert.assertNotNull(el);
		}
		
		[Test(description="Tests that Element can only belong to the Documents they were created on")]
		public function elementsMustBelongToDocument():void
		{
			var el:IElement = this._document.createElement("body");
			
			this._document.appendChild(el);
			
			Assert.assertTrue(this._document.hasChildNodes());
			
			Assert.assertEquals(1, this._document.childNodes.length);
			
			var document:Document = new Document(new DocumentType(null, "smil"));
			var wrongChild:IElement = document.createElement("body");
			
			try
			{
				this._document.appendChild(wrongChild);
				
				// worked?!
				Assert.fail("Should not be able to append a child from another document");
			}
			catch (ex:DOMException)
			{
				Assert.assertEquals(1, this._document.childNodes.length);
			}			
		}
		
		[Test(description="Tests the creation of new attributes")]
		public function newAttributes():void
		{
			var el:IElement = this._document.createElement("body");
			Assert.assertNotNull(el);
			Assert.assertNotUndefined(el);
			
			el.setAttribute("hello", "world");
			
			Assert.assertTrue(el.hasAttribute("hello"));
		}
		
		[Test(description="Tests updating an attribute on an element")]
		public function updatingAttributes():void
		{
			var el:IElement = this._document.createElement("body");
			Assert.assertNotNull(el);
			
			el.setAttribute("hello", "world");
			
			Assert.assertTrue(el.hasAttribute("hello"));
			
			el.setAttribute("hello", "flexunit");
			
			Assert.assertTrue(el.hasAttribute("hello"));
			
			Assert.assertEquals(el.getAttribute("hello"), "flexunit");
		}
		
		[Test(description="Tests removing an attribute on an element")]
		public function removingAttributes():void
		{
			var el:IElement = this._document.createElement("body");
			Assert.assertNotNull(el);
			
			el.setAttribute("hello", "world");
			
			Assert.assertTrue(el.hasAttribute("hello"));
			
			el.removeAttribute("hello");
			
			Assert.assertFalse(el.hasAttribute("hello"));
		}
		
		[Test(description="Tests a DOM element can correctly store its children")]
		public function domStoresChildren():void
		{
			var el:Element = (this._multiDocument.getElementById("holder") as Element);
			
			Assert.assertNotNull(el);
			
			Assert.assertEquals(4, el.length);
		}
	}
}