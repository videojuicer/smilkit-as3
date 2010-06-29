package org.smilkit.spec.tests.dom
{
	import flexunit.framework.Assert;
	
	import org.flexunit.async.Async;
	import org.smilkit.dom.Document;
	import org.smilkit.dom.Element;
	import org.smilkit.dom.events.EventListener;
	import org.smilkit.dom.events.MutationEvent;
	import org.smilkit.parsers.BostonDOMParser;
	import org.smilkit.spec.Fixtures;
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
			var asyncListener:Function = Async.asyncHandler(this, this.onEventDispatched, 2000, null,this.onEventTimeout);
			var listener:EventListener = new EventListener(asyncListener);
			
			(this._document as Document).addEventListener(MutationEvent.DOM_NODE_REMOVED, listener, false);
			
			this._document.removeChild(this._document.firstChild);
		}
		
		[Test(async,description="Test listening for an attribute mutation event")]
		public function listenForAttributeMutation():void
		{
			var asyncListener:Function = Async.asyncHandler(this, this.onAttributeMutation, 2000, null, this.onAttributeMutationTimeout);
			var listener:EventListener = new EventListener(asyncListener);
			
			(this._document as Document).addEventListener(MutationEvent.DOM_ATTR_MODIFIED, listener, false);
			
			((this._document as Document).firstChild as Element).setAttribute("test", "hello world");
		}
		
		protected function onEventDispatched(e:MutationEvent, passThru:Object):void
		{
			Assert.assertNotNull(e.target);
		}
		
		protected function onEventTimeout(passThru:Object):void
		{
			Assert.fail("Timeout occured whilst waiting for a mutation event on the DOM.");
		}
		
		protected function onAttributeMutation(e:MutationEvent, passThru:Object):void
		{
			Assert.fail("Worked!");
		}
		
		protected function onAttributeMutationTimeout(passThru:Object):void
		{
			Assert.fail("Timeout occured whilst waiting for a attribute mutation event on the DOM.");
		}
	}
}