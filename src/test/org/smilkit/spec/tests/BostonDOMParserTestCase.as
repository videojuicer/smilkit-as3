package org.smilkit.spec.tests
{
	import flexunit.framework.Assert;
	
	import org.smilkit.parsers.BostonDOMParser;
	import org.smilkit.w3c.dom.IDocument;
	
	public class BostonDOMParserTestCase
	{		
		[Test(description="Parse a SMIL document")]
		public function parseSMILDocument():void
		{
			var xml:String = "<?xml version=\"1.0\"?><smil><head><layout><region xml:id=\"root\" width=\"100%\" height=\"100%\" /></layout></head><body><video src=\"http://media.smilkit.org/demo.mp4\" region=\"root\" /></body></smil>";
			
			var parser:BostonDOMParser = new BostonDOMParser();
			var doc:IDocument = parser.parse(xml);
			
			Assert.assertNotNull(doc);
		}
	}
}