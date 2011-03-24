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
	
	public class ParentNodeTestCase
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
		
		[Test(description="Ensures that all nodes in a parsed document are in an attached state")]
		public function documentParserAttachesNodes():void
		{
			Assert.assertFalse(this._document.orphaned);
			Assert.assertFalse(this._document.firstChild.orphaned);
		}
		
		[Test(description="Ensures that all nodes in an orphaned tree are unorphaned when the root gets a parent")]
		public function orphanedTreeUnorphanedOnParentSet():void
		{
			
		}
		
		[Test(description="Ensures that all nodes in a tree are orphaned when the tree's root is removed from its parent")]
		public function attachedTreeOrphanedOnParentRemoved():void
		{
			
		}
		
	}
}