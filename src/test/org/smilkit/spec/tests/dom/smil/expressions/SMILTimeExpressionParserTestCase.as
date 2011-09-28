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