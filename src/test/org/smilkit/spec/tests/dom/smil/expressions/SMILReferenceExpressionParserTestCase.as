package org.smilkit.spec.tests.dom.smil.expressions
{
	import flexunit.framework.Assert;
	
	import org.smilkit.dom.smil.ElementTestContainer;
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.dom.smil.expressions.SMILReferenceExpressionParser;
	import org.smilkit.parsers.BostonDOMParser;
	import org.smilkit.spec.Fixtures;
	
	public class SMILReferenceExpressionParserTestCase
	{
		protected var _parser:SMILReferenceExpressionParser = null;
		protected var _document:SMILDocument = null;
		
		[Before]
		public function setUp():void
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			this._document = parser.parse(Fixtures.BASIC_SMIL_XML) as SMILDocument;
			
			this._parser = new SMILReferenceExpressionParser((this._document.getElementById("body") as ElementTestContainer));
		}
		
		[Test(description="Tests a basic sum using a reference to another element")]
		public function testsBasicSumWithSMILTimesAndReferences():void
		{
			var expression:String = "content.begin";
			var results:Number = this._parser.begin(expression);
			
			Assert.assertEquals(0, results);
			
			expression = "content.end";
			results = this._parser.begin(expression);
			
			Assert.assertEquals(10, results);
			
			expression = "content.end + 10s";
			results = this._parser.begin(expression);
			
			Assert.assertEquals(20, results);
		}
	}
}