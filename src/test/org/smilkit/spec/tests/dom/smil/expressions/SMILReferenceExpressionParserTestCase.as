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
			
			//Assert.assertEquals(10, results);
			
			expression = "content.end + 10s";
			results = this._parser.begin(expression);
			
			Assert.assertEquals(20, results);
		}
	}
}