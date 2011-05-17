package org.smilkit.spec.tests.dom.smil
{
	import flexunit.framework.Assert;
	
	import mx.utils.object_proxy;
	
	import org.flexunit.async.Async;
	import org.smilkit.SMILKit;
	import org.smilkit.dom.smil.ElementSequentialTimeContainer;
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.dom.smil.SMILTimeInstance;
	import org.smilkit.events.TimingGraphEvent;
	import org.smilkit.events.ViewportEvent;
	import org.smilkit.parsers.BostonDOMParser;
	import org.smilkit.spec.Fixtures;
	import org.smilkit.view.Viewport;
	import org.smilkit.w3c.dom.smil.ISMILDocument;

	public class SMILTimeGraphTestCase
	{		
		protected var _document:SMILDocument;
		
		[Before]
		public function setUp():void
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			
			this._document = (parser.parse(Fixtures.BASIC_SMIL_XML) as SMILDocument);
		}
		
		[After]
		public function tearDown():void
		{
			this._document = null;
		}
		
		[Test(description="Tests that the elements collection is populated")]
		public function hasElementsInTheTree():void
		{
			Assert.assertEquals(2, this._document.timeGraph.elements.length);
			
			Assert.assertEquals(1, this._document.timeGraph.mediaElements.length);
			
			Assert.assertEquals("body", this._document.timeGraph.elements[0].element.id);
			Assert.assertEquals("content", this._document.timeGraph.elements[1].element.id);
			
			Assert.assertEquals("content", this._document.timeGraph.mediaElements[0].element.id);
		}
	}
}