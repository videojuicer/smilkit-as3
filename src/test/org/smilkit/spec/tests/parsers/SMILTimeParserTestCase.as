package org.smilkit.spec.tests.parsers
{
	import org.flexunit.Assert;
	import org.smilkit.parsers.SMILTimeParser;

	public class SMILTimeParserTestCase
	{
		protected var _parser:SMILTimeParser;
		
		[Before]
		public function setUp():void
		{
			this._parser = new SMILTimeParser(null);
		}
		
		[Test(description="Tests the parser can identify smil time strings correctly")]
		public function canIdentifySMILTimeStrings():void
		{
			Assert.assertTrue(this._parser.identifies("2330h"));
			Assert.assertTrue(this._parser.identifies("230min"));
			Assert.assertTrue(this._parser.identifies("2024ms"));
			Assert.assertTrue(this._parser.identifies("2033s"));
			
			Assert.assertTrue(this._parser.identifies("20:30"));
			Assert.assertTrue(this._parser.identifies("20:30:40"));
			
			Assert.assertFalse(this._parser.identifies("h2330"));
			Assert.assertFalse(this._parser.identifies("23h0"));
			Assert.assertFalse(this._parser.identifies("20ms24"));
			Assert.assertFalse(this._parser.identifies("s2033"));
			
			Assert.assertFalse(this._parser.identifies("20-30"));
			Assert.assertFalse(this._parser.identifies("20-30-40"));
		}
	}
}