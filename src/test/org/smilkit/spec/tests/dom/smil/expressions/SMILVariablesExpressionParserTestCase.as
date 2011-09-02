package org.smilkit.spec.tests.dom.smil.expressions
{
	import flexunit.framework.Assert;
	
	import org.smilkit.SMILKit;
	import org.smilkit.dom.DocumentType;
	import org.smilkit.dom.smil.ElementTestContainer;
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.dom.smil.expressions.SMILDocumentVariables;
	import org.smilkit.dom.smil.expressions.SMILVariableExpressionParser;
	import org.smilkit.parsers.BostonDOMParser;
	import org.smilkit.spec.Fixtures;
	
	public class SMILVariablesExpressionParserTestCase
	{
		protected var _document:SMILDocument = null;
		protected var _parser:SMILVariableExpressionParser = null;
		
		[Before]
		public function setUp():void
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			this._document = parser.parse(Fixtures.BASIC_SMIL_XML) as SMILDocument;
			
			this._parser = new SMILVariableExpressionParser((this._document.getElementById("body") as ElementTestContainer));
		}
		
		[Test(description="Tests a basic expression test against the systemBitrate() method")]
		public function testsAgainstSystemBitrate():void
		{
			Assert.assertFalse(this._parser.begin("smil-bitrate() == 100"));
			
			this._document.variables.set(SMILDocumentVariables.SYSTEM_BITRATE, 100);
			
			Assert.assertTrue(this._parser.begin("smil-bitrate() == 100"));
			
			Assert.assertTrue(this._parser.begin("smil-bitrate() < 101"));
			
			Assert.assertTrue(this._parser.begin("smil-bitrate() > 99"));
			
			Assert.assertTrue(this._parser.begin("smil-bitrate() > 0"));
			
			Assert.assertFalse(this._parser.begin("smil-bitrate() > 100"));
			
			Assert.assertFalse(this._parser.begin("smil-bitrate() == 9000"));
			
			Assert.assertTrue(this._parser.begin("(smil-bitrate() < 101) && (smil-bitrate() > 99)"));
			
			Assert.assertFalse(this._parser.begin("(smil-bitrate() < 101) && (smil-bitrate() == 99)"));
		}
	}
}