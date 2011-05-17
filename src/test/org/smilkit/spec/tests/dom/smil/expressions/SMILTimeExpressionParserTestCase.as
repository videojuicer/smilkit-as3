package org.smilkit.spec.tests.dom.smil.expressions
{
	import flexunit.framework.Assert;
	
	import org.smilkit.dom.smil.expressions.SMILTimeExpressionParser;

	public class SMILTimeExpressionParserTestCase
	{
		protected var _parser:SMILTimeExpressionParser;
		
		[Before]
		public function setUp():void
		{
			this._parser = new SMILTimeExpressionParser(null);
		}
		
		[Test(description="Tests a basic sum using one SMIL time")]
		public function testsBasicSumWithSMILTime():void
		{
			var expression:String = "100s + 5";
			var results:Number = this._parser.begin(expression);
			
			Assert.assertEquals(105, results);
			
			expression = "100s - 5";
			results = this._parser.begin(expression);
			
			Assert.assertEquals(95, results);
			
			expression = "100s";
			results = this._parser.begin(expression);
			
			Assert.assertEquals(100, results);
		}
		
		[Test(description="Tests a basic sum using multiple SMIL times")]
		public function testsBasicSumWithSMILTimes():void
		{
			var expression:String = "100s + 0:05";
			var results:Number = this._parser.begin(expression);
			
			Assert.assertEquals(105, results);
			
			expression = "100s - 0:05";
			results = this._parser.begin(expression);
			
			Assert.assertEquals(95, results);
		}
	}
}