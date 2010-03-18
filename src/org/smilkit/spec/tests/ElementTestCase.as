package org.smilkit.spec.tests
{
	import flexunit.framework.Assert;
	
	import org.smilkit.dom.Document;
	import org.smilkit.dom.DocumentType;
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.IElement;
	
	public class ElementTestCase
	{
		private var _document:IDocument;
		
		public function ElementTestCase()
		{
			this._document = new Document(new DocumentType(null, "smil"));
		}
		
		[Test(description="Tests the creation of an Element on a Document.")]
		public function creation():void
		{
			var el:IElement = this._document.createElement("body");
			Assert.assertNotNull(el);
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
	}
}