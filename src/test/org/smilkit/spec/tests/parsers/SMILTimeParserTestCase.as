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