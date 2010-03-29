package org.smilkit.spec.tests
{
	import flexunit.framework.Assert;
	
	import org.smilkit.dom.Document;
	import org.smilkit.dom.DocumentType;
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.IElement;
	import org.smilkit.w3c.dom.INodeList;

	//import org.smilkit.w3c.dom.INodeList;
	
	public class DocumentTestCase
	{
		public function DocumentTestCase()
		{
			
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
	}
}