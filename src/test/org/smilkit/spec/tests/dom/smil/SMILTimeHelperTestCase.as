package org.smilkit.spec.tests.dom.smil
{
	import flexunit.framework.Assert;
	
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.dom.smil.SMILMediaElement;
	import org.smilkit.dom.smil.SMILTimeHelper;
	import org.smilkit.dom.smil.Time;
	import org.smilkit.parsers.BostonDOMParser;
	import org.smilkit.spec.Fixtures;
	
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
			Assert.assertEquals(Time.INDEFINITE, SMILTimeHelper.multiply(this._timeTenSeconds, this._timeIndefinite).resolvedOffset);
			Assert.assertEquals(Time.INDEFINITE, SMILTimeHelper.multiply(this._timeIndefinite, this._timeIndefinite).resolvedOffset);
			Assert.assertEquals(Time.UNRESOLVED, SMILTimeHelper.multiply(this._timeUnresolved, this._timeTenSeconds).resolvedOffset);
		}
		
		[Test(description="Tests that two Time objects can be added together")]
		public function sumCalculatesAddition():void
		{
			Assert.assertEquals(20, SMILTimeHelper.add(this._timeTenSeconds, this._timeTenSeconds).resolvedOffset);
			Assert.assertEquals(Time.INDEFINITE, SMILTimeHelper.add(this._timeIndefinite, this._timeTenSeconds).resolvedOffset);
			Assert.assertEquals(Time.INDEFINITE, SMILTimeHelper.add(this._timeTenSeconds, this._timeIndefinite).resolvedOffset);
			Assert.assertEquals(Time.INDEFINITE, SMILTimeHelper.add(this._timeIndefinite, this._timeIndefinite).resolvedOffset);
			Assert.assertEquals(Time.UNRESOLVED, SMILTimeHelper.add(this._timeUnresolved, this._timeIndefinite).resolvedOffset);
			Assert.assertEquals(Time.UNRESOLVED, SMILTimeHelper.add(this._timeTenSeconds, this._timeUnresolved).resolvedOffset);
		}
		
		[Test(description="Tests that two Time objects can be subtracted")]
		public function sumCalculatesSubtraction():void
		{
			Assert.assertEquals(0, SMILTimeHelper.subtract(this._timeTenSeconds, this._timeTenSeconds).resolvedOffset);
			Assert.assertEquals(Time.INDEFINITE, SMILTimeHelper.subtract(this._timeIndefinite, this._timeTenSeconds).resolvedOffset);
			Assert.assertEquals(Time.INDEFINITE, SMILTimeHelper.subtract(this._timeTenSeconds, this._timeIndefinite).resolvedOffset);
			Assert.assertEquals(Time.INDEFINITE, SMILTimeHelper.subtract(this._timeIndefinite, this._timeIndefinite).resolvedOffset);
			Assert.assertEquals(Time.UNRESOLVED, SMILTimeHelper.subtract(this._timeUnresolved, this._timeIndefinite).resolvedOffset);
			Assert.assertEquals(Time.UNRESOLVED, SMILTimeHelper.subtract(this._timeTenSeconds, this._timeUnresolved).resolvedOffset);
		}
		
		[Test(description="Tests the minimization of multiple Time objects")]
		public function calculatesMinimization():void
		{
			Assert.assertEquals(0, SMILTimeHelper.min(this._timeZero, this._timeTenSeconds).resolvedOffset);
			Assert.assertEquals(6, SMILTimeHelper.min(this._timeSixSeconds, this._timeTenSeconds).resolvedOffset);
			Assert.assertEquals(10, SMILTimeHelper.min(this._timeTenSeconds, this._timeIndefinite).resolvedOffset);
			Assert.assertEquals(10, SMILTimeHelper.min(this._timeTenSeconds, this._timeUnresolved).resolvedOffset);
			Assert.assertEquals(Time.INDEFINITE, SMILTimeHelper.min(this._timeIndefinite, this._timeUnresolved).resolvedOffset);
		}
		
		[Test(description="Tests the maximization of multiple Time objects")]
		public function calculatesMaximization():void
		{
			Assert.assertEquals(10, SMILTimeHelper.max(this._timeZero, this._timeTenSeconds).resolvedOffset);
			Assert.assertEquals(10, SMILTimeHelper.max(this._timeSixSeconds, this._timeTenSeconds).resolvedOffset);
			Assert.assertEquals(Time.INDEFINITE, SMILTimeHelper.max(this._timeTenSeconds, this._timeIndefinite).resolvedOffset);
			Assert.assertEquals(Time.UNRESOLVED, SMILTimeHelper.max(this._timeTenSeconds, this._timeUnresolved).resolvedOffset);
			Assert.assertEquals(Time.UNRESOLVED, SMILTimeHelper.max(this._timeIndefinite, this._timeUnresolved).resolvedOffset);
		}
	}
}