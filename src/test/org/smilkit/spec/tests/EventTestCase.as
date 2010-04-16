package org.smilkit.spec.tests
{
	import flexunit.framework.Assert;
	
	import org.smilkit.dom.Document;
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
		
		[Test(description="Test dispatching mutation events on a node")]
		public function testMutations():void
		{
			this._document.firstChild.nodeValue = "new value";
			
			if ((this._document as Document).changes == 0)
			{
				Assert.fail("Document should of experienced a mutation change.");
			}
		}
		
		[Test(description="Test listening for an event")]
		public function listenForEvent():void
		{
			var listener:IEventListener = new EventListener(function(e:MutationEvent):void {
				Assert.assertNotNull(e.target);
			});
			
			(this._document as Document).addEventListener(MutationEvent.DOM_NODE_REMOVED, listener, false);
			
			this._document.removeChild(this._document.firstChild);
		}
	}
}