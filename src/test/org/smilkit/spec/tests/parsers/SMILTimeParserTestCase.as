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
			
			Assert.assertTrue(this._parser.identifies("2330.5h"));
			Assert.assertTrue(this._parser.identifies("230.2min"));
			Assert.assertTrue(this._parser.identifies("2024ms"));
			Assert.assertTrue(this._parser.identifies("2033.67s"));
			
			Assert.assertTrue(this._parser.identifies("20:30"));
			Assert.assertTrue(this._parser.identifies("20:30:40"));
			
			Assert.assertFalse(this._parser.identifies("h2330"));
			Assert.assertFalse(this._parser.identifies("23h0"));
			Assert.assertFalse(this._parser.identifies("20ms24"));
			Assert.assertFalse(this._parser.identifies("s2033"));
			
			Assert.assertFalse(this._parser.identifies("20-30"));
			Assert.assertFalse(this._parser.identifies("20-30-40"));
		}
		
		[Test(description="Tests the parser can parse floating times correctly")]
		public function canParseFloatingTimes():void
		{
			Assert.assertEquals(5000, this._parser.parse("5s").milliseconds);
			Assert.assertEquals(5200, this._parser.parse("5.2s").milliseconds);
			Assert.assertEquals(5000, this._parser.parse("5.0s").milliseconds);
		}
	}
}