package org.smilkit.spec.tests
{
	import flexunit.framework.Assert;
	
	import org.smilkit.dom.Element;
	import org.smilkit.dom.smil.Time;
	import org.smilkit.parsers.BostonDOMParser;
	import org.smilkit.spec.Fixtures;
	import org.smilkit.w3c.dom.IElement;
	import org.smilkit.w3c.dom.INodeList;
	import org.smilkit.w3c.dom.smil.ISMILDocument;
	import org.smilkit.w3c.dom.smil.ISMILMediaElement;
	import org.smilkit.w3c.dom.smil.ITimeList;

	public class TimeTestCase
	{		
		protected var _document:ISMILDocument;
		
		[Before]
		public function setUp():void
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			this._document = (parser.parse(Fixtures.TIMED_SMIL_XML) as ISMILDocument);
		}
		
		[Test(description="Tests resolving a flat-packed assets, i.e. all the times are defined in the SMIL")]
		public function resolvesFlatTime():void
		{
			var preroll:ISMILMediaElement = (this._document.getElementById("preroll") as ISMILMediaElement);
			
			Assert.assertNotNull(preroll)
				
			var prerollTime:Time = (preroll.begin.item(0) as Time);
			var prerollEnd:Time = (preroll.end.item(0) as Time);
			
			Assert.assertNotNull(prerollTime);
			Assert.assertNotNull(prerollEnd);
			
			prerollTime.resolve();
			prerollEnd.resolve();
			
			var content:ISMILMediaElement = (this._document.getElementById("content") as ISMILMediaElement);
			
			Assert.assertNotNull(content)
			
			var contentTime:Time = (content.begin.item(0) as Time);
			var contentEnd:Time = (content.end.item(0) as Time);
			
			Assert.assertNotNull(contentTime);
			Assert.assertNotNull(contentEnd);
			
			contentTime.resolve();
			contentEnd.resolve();
		}
	}
}