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
package org.smilkit.spec.tests.dom.smil
{
	import flexunit.framework.Assert;
	
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.dom.smil.SMILMediaElement;
	import org.smilkit.dom.smil.Time;
	import org.smilkit.dom.smil.time.SMILTimeHelper;
	import org.smilkit.parsers.BostonDOMParser;
	import org.smilkit.spec.Fixtures;
	import org.smilkit.time.Times;
	
	public class SMILTimeHelperTestCase
	{		
		protected var _timeZero:Time = null;
		protected var _timeUnresolved:Time = null;
		protected var _timeIndefinite:Time = null;
		
		protected var _timeSixSeconds:Time = null;
		protected var _timeTenSeconds:Time = null;
		
		[Before]
		public function setup():void
		{
			this._timeZero = new Time(null, false, "0s");
			
			this._timeUnresolved = new Time(null, false, "unresolved");
			this._timeIndefinite = new Time(null, false, "indefinite");
			
			this._timeSixSeconds = new Time(null, false, "6s");
			this._timeTenSeconds = new Time(null, false, "10s");
		}
		
		[Test(description="Tests that two Time objects can be multiplied together")]
		public function sumCalculatesMultiplication():void
		{
			Assert.assertEquals(0, SMILTimeHelper.multiply(this._timeZero, this._timeTenSeconds).resolvedOffset);
			Assert.assertEquals(0, SMILTimeHelper.multiply(this._timeZero, this._timeIndefinite).resolvedOffset);
			Assert.assertEquals(100, SMILTimeHelper.multiply(this._timeTenSeconds, this._timeTenSeconds).resolvedOffset);
			Assert.assertEquals(Times.INDEFINITE, SMILTimeHelper.multiply(this._timeTenSeconds, this._timeIndefinite).resolvedOffset);
			Assert.assertEquals(Times.INDEFINITE, SMILTimeHelper.multiply(this._timeIndefinite, this._timeIndefinite).resolvedOffset);
			Assert.assertEquals(Times.UNRESOLVED, SMILTimeHelper.multiply(this._timeUnresolved, this._timeTenSeconds).resolvedOffset);
		}
		
		[Test(description="Tests that two Time objects can be added together")]
		public function sumCalculatesAddition():void
		{
			Assert.assertEquals(20, SMILTimeHelper.add(this._timeTenSeconds, this._timeTenSeconds).resolvedOffset);
			Assert.assertEquals(Times.INDEFINITE, SMILTimeHelper.add(this._timeIndefinite, this._timeTenSeconds).resolvedOffset);
			Assert.assertEquals(Times.INDEFINITE, SMILTimeHelper.add(this._timeTenSeconds, this._timeIndefinite).resolvedOffset);
			Assert.assertEquals(Times.INDEFINITE, SMILTimeHelper.add(this._timeIndefinite, this._timeIndefinite).resolvedOffset);
			Assert.assertEquals(Times.UNRESOLVED, SMILTimeHelper.add(this._timeUnresolved, this._timeIndefinite).resolvedOffset);
			Assert.assertEquals(Times.UNRESOLVED, SMILTimeHelper.add(this._timeTenSeconds, this._timeUnresolved).resolvedOffset);
		}
		
		[Test(description="Tests that two Time objects can be subtracted")]
		public function sumCalculatesSubtraction():void
		{
			Assert.assertEquals(0, SMILTimeHelper.subtract(this._timeTenSeconds, this._timeTenSeconds).resolvedOffset);
			Assert.assertEquals(Times.INDEFINITE, SMILTimeHelper.subtract(this._timeIndefinite, this._timeTenSeconds).resolvedOffset);
			Assert.assertEquals(Times.INDEFINITE, SMILTimeHelper.subtract(this._timeTenSeconds, this._timeIndefinite).resolvedOffset);
			Assert.assertEquals(Times.INDEFINITE, SMILTimeHelper.subtract(this._timeIndefinite, this._timeIndefinite).resolvedOffset);
			Assert.assertEquals(Times.UNRESOLVED, SMILTimeHelper.subtract(this._timeUnresolved, this._timeIndefinite).resolvedOffset);
			Assert.assertEquals(Times.UNRESOLVED, SMILTimeHelper.subtract(this._timeTenSeconds, this._timeUnresolved).resolvedOffset);
		}
		
		[Test(description="Tests the minimization of multiple Time objects")]
		public function calculatesMinimization():void
		{
			Assert.assertEquals(0, SMILTimeHelper.min(this._timeZero, this._timeTenSeconds).resolvedOffset);
			Assert.assertEquals(6, SMILTimeHelper.min(this._timeSixSeconds, this._timeTenSeconds).resolvedOffset);
			Assert.assertEquals(10, SMILTimeHelper.min(this._timeTenSeconds, this._timeIndefinite).resolvedOffset);
			Assert.assertEquals(10, SMILTimeHelper.min(this._timeTenSeconds, this._timeUnresolved).resolvedOffset);
			Assert.assertEquals(Times.INDEFINITE, SMILTimeHelper.min(this._timeIndefinite, this._timeUnresolved).resolvedOffset);
		}
		
		[Test(description="Tests the maximization of multiple Time objects")]
		public function calculatesMaximization():void
		{
			Assert.assertEquals(10, SMILTimeHelper.max(this._timeZero, this._timeTenSeconds).resolvedOffset);
			Assert.assertEquals(10, SMILTimeHelper.max(this._timeSixSeconds, this._timeTenSeconds).resolvedOffset);
			Assert.assertEquals(Times.INDEFINITE, SMILTimeHelper.max(this._timeTenSeconds, this._timeIndefinite).resolvedOffset);
			Assert.assertEquals(Times.UNRESOLVED, SMILTimeHelper.max(this._timeTenSeconds, this._timeUnresolved).resolvedOffset);
			Assert.assertEquals(Times.UNRESOLVED, SMILTimeHelper.max(this._timeIndefinite, this._timeUnresolved).resolvedOffset);
		}
	}
}