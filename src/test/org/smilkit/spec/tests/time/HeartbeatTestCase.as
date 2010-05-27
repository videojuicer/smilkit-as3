package org.smilkit.spec.tests.time
{
	import flexunit.framework.Assert;
	
	import org.flexunit.async.Async;
	import org.smilkit.events.ViewportEvent;
	import org.smilkit.time.Heartbeat;
	import org.smilkit.view.Viewport;

	public class HeartbeatTestCase
	{		
		protected var _viewport:Viewport;
		
		[Before]
		public function setUp():void
		{
			this._viewport = new Viewport();
		}
		
		[After]
		public function tearDown():void
		{
			this._viewport = null;
		}
		
		[Test(async, description="Tests that the Hearbeat has an offSet")]
		public function hasOffSet():void
		{
			var asyncHasOffSetCheck:Function = Async.asyncHandler(this, handleHasOffSet, 5000, null, handleHasOffSetTimeOut);
			this._viewport.addEventListener(ViewportEvent.REFRESH_COMPLETE, asyncHasOffSetCheck, false, 0, true);
			this._viewport.location = "http://sixty.im/demo.smil";	
		}
		
		protected function handleHasOffSet(event:ViewportEvent, passThroughData:Object):void
		{
			var heartBeat:Heartbeat = this._viewport.heartbeat;
			Assert.assertEquals(0, heartBeat.offset);
		}
		
		protected function handleHasOffSetTimeOut(passThroughData:Object):void
		{
			Assert.fail( "Timeout reached before viewport refreshed: HeartbeatTestCase:handleHasOffset");
		}	
		
		[Test(async, description="Tests that the Heartbeat has beatsPerSecond")]
		public function hasBeatsPerSecond():void
		{
			var asyncHasBeatsPerSecondCheck:Function = Async.asyncHandler(this, handleHasBeatsPerSecond, 5000, null, handleHasBeatsPerSecond);
			this._viewport.addEventListener(ViewportEvent.REFRESH_COMPLETE, asyncHasBeatsPerSecondCheck, false, 0, true);
			this._viewport.location = "http://sixty.im/demo.smil";	
		}
		
		protected function handleHasBeatsPerSecond(event:ViewportEvent, passThroughData:Object):void
		{
			var heartBeat:Heartbeat = this._viewport.heartbeat;
			Assert.assertEquals(1000 / Heartbeat.BPS_5, heartBeat.beatsPerSecond);
		}
		
		protected function handleHasBeatsPerSecondTimeOut(passThroughData:Object):void
		{
			Assert.fail( "Timeout reached before viewport refreshed: HeartbeatTestCase:handleHasBestsPerSecond");
		}
		
		[Test(async, description="Tests that the Heartbeat has slowBeats")]
		public function hasSlowBeats():void
		{
			var asyncHasSlowBeatsCheck:Function = Async.asyncHandler(this, handleHasSlowBeats, 5000, null, handleHasSlowBeats);
			this._viewport.addEventListener(ViewportEvent.REFRESH_COMPLETE, asyncHasSlowBeatsCheck, false, 0, true);
			this._viewport.location = "http://sixty.im/demo.smil";	
		}
		
		protected function handleHasSlowBeats(event:ViewportEvent, passThroughData:Object):void
		{
			var heartBeat:Heartbeat = this._viewport.heartbeat;
			Assert.assertEquals(0, heartBeat.slowBeats);
		}
		
		protected function handleHasSlowBeatsSecondTimeOut(passThroughData:Object):void
		{
			Assert.fail( "Timeout reached before viewport refreshed: HeartbeatTestCase:handleHasSlowBeats");
		}
		
	}
}