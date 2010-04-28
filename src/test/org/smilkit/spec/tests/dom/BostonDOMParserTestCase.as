package org.smilkit.spec.tests.dom
{
	import flexunit.framework.Assert;
	
	import org.smilkit.parsers.BostonDOMParser;
	import org.smilkit.spec.Fixtures;
	import org.smilkit.w3c.dom.IDocument;
	
	public class BostonDOMParserTestCase
	{		
		[Test(description="Parse a SMIL document")]
		public function parseSMILDocument():void
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			var doc:IDocument = parser.parse(Fixtures.BASIC_SMIL_XML);
			
			Assert.assertNotNull(doc);
		}
	}
}