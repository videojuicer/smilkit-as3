/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version 1.1
 * (the "License"); you may not use this file except in compliance with the
 * License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 *
 * The Original Code is the SMILKit library.
 *
 * The Initial Developer of the Original Code is
 * Videojuicer Ltd. (UK Registered Company Number: 05816253).
 * Portions created by the Initial Developer are Copyright (C) 2010
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 * 	Dan Glegg
 * 	Adam Livesley
 *
 * ***** END LICENSE BLOCK ***** */
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