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
			var passThru:Object = { childCount: (element.parentNode as ParentNode).length };
			var asyncListener:Function = Async.asyncHandler(this, this.onEventDispatched, 2000, passThru, this.onEventTimeout);

			(this._document as Document).addEventListener(MutationEvent.DOM_NODE_REMOVED, asyncListener, false);
			element.parentNode.removeChild(element);
		}
		
		[Test(async,description="Test listening for an attribute mutation event")]
		public function listenForAttributeMutation():void
		{
			var asyncListener:Function = Async.asyncHandler(this, this.onAttributeMutation, 2000, null, this.onAttributeMutationTimeout);

			(this._document as Document).addEventListener(MutationEvent.DOM_ATTR_MODIFIED, asyncListener, false);
			
			((this._document as Document).firstChild as Element).setAttribute("test", "hello world");
		}
		
		protected function onEventDispatched(e:MutationEvent, passThru:Object = null):void
		{
			var bodyElement:ParentNode = (this._document.getElementById("body") as ParentNode);
			
			Assert.assertNull(this._document.getElementById("content"));
			Assert.assertEquals((passThru.childCount - 1), bodyElement.length);
		}
		
		protected function onEventTimeout(passThru:Object = null):void
		{
			Assert.fail("Timeout occured whilst waiting for a mutation event on the DOM.");
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