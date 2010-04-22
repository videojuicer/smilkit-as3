package org.smilkit.spec.tests
{
	import flexunit.framework.Assert;
	
	import org.smilkit.dom.smil.Time;
	import org.smilkit.parsers.BostonDOMParser;
	import org.smilkit.spec.Fixtures;
	import org.smilkit.w3c.dom.smil.ISMILDocument;
	import org.smilkit.w3c.dom.smil.ISMILMediaElement;

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
			
			Assert.assertNotNull(preroll);
			
			var prerollTime:Time = (preroll.begin.item(0) as Time);
			
			Assert.assertNotNull(prerollTime);
		}
	}
}