package org.smilkit.spec.tests.dom
{
	import flexunit.framework.Assert;
	
	import org.flexunit.async.Async;
	import org.smilkit.dom.Document;
	import org.smilkit.dom.Element;
	import org.smilkit.dom.ParentNode;
	import org.smilkit.dom.events.MutationEvent;
	import org.smilkit.dom.smil.SMILMediaElement;
	import org.smilkit.parsers.BostonDOMParser;
	import org.smilkit.spec.Fixtures;
	import org.smilkit.w3c.dom.IElement;
	import org.smilkit.w3c.dom.events.IEventListener;
	import org.smilkit.w3c.dom.smil.ISMILDocument;

	public class EventTestCase
	{		
		protected var _document:ISMILDocument;
		
		[Before]
		public function setUp():void
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			this._document = (parser.parse(Fixtures.BASIC_SMIL_XML) as ISMILDocument);
		}
		
		[After]
		public function tearDown():void
		{
			this._document = null;
		}
		
		[Test(description="Test dispatching mutation events on a node")]
		public function testMutations():void
		{
			this._document.firstChild.nodeValue = "new value";
			
			if ((this._document as Document).changes == 0)
			{
				Assert.fail("Document should of experienced a mutation change.");
			}
		}
		
		[Test(async,description="Test listening for an event")]
		public function listenForEvent():void
		{
			var element:SMILMediaElement = (this._document.getElementById("content") as SMILMediaElement);
			var passThru:Object = { childCount: (element.parentNode as ParentNode).length, changes: element.changes };
			
			var asyncListener:Function = Async.asyncHandler(this, this.onNodeRemovedFromDocument, 4000, passThru, this.onNodeRemovedFromDocumentTimeout);
			element.addEventListener(MutationEvent.DOM_NODE_REMOVED_FROM_DOCUMENT, asyncListener, false);
			
			element.parentNode.removeChild(element);
		}
		
		protected function onNodeRemovedFromDocument(e:MutationEvent, passThru:Object = null):void
		{
			var bodyElement:ParentNode = (this._document.getElementById("body") as ParentNode);
			
			// the remove shouldn't of happened yet (seems stupid but w3c says so)
			Assert.assertNotNull(this._document.getElementById("content")); 
			Assert.assertEquals(passThru.childCount, bodyElement.length);
			Assert.assertEquals(passThru.changes, bodyElement.changes);
			
			// we make another listen for the subtree here (so that we can actually check the node was removed)
			// we do it now rather than before because the subtree is modified as the node is removing
			var asyncListener:Function = Async.asyncHandler(this, this.onSubtreeModified, 2000, passThru, this.onSubtreeModifiedTimeout);
			bodyElement.addEventListener(MutationEvent.DOM_SUBTREE_MODIFIED, asyncListener, false);
		}
		
		protected function onNodeRemovedFromDocumentTimeout(passThru:Object = null):void
		{
			Assert.fail("Timeout occured whilst waiting for a removed node from document event on the DOM.");
		}
		
		protected function onSubtreeModified(e:MutationEvent, passThru:Object = null):void
		{
			var bodyElement:ParentNode = (this._document.getElementById("body") as ParentNode);
			
			Assert.assertNull(this._document.getElementById("content")); 
			Assert.assertEquals((passThru.childCount - 1), bodyElement.length);
			Assert.assertEquals((passThru.changes + 1), bodyElement.changes);
		}
		
		protected function onSubtreeModifiedTimeout(passThru:Object = null):void
		{
			Assert.fail("Timeout occured whilst waiting for a subtree modified event on the DOM.");
		}
		
		[Test(async,description="Test listening for an attribute mutation event")]
		public function listenForAttributeMutation():void
		{
			var asyncListener:Function = Async.asyncHandler(this, this.onAttributeMutation, 2000, null, this.onAttributeMutationTimeout);

			(this._document as Document).addEventListener(MutationEvent.DOM_ATTR_MODIFIED, asyncListener, false);
			
			((this._document as Document).firstChild as Element).setAttribute("test", "hello world");
		}
		
		protected function onAttributeMutation(e:MutationEvent, passThru:Object = null):void
		{
			var attributeValue:String = ((this._document as Document).firstChild as Element).getAttribute("test");
			
			Assert.assertEquals("hello world", attributeValue);
		}
		
		protected function onAttributeMutationTimeout(passThru:Object = null):void
		{
			Assert.fail("Timeout occured whilst waiting for a attribute mutation event on the DOM.");
		}
	}
}