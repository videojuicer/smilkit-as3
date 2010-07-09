package org.smilkit.spec.tests.time
{
	import flexunit.framework.Assert;
	
	import org.flexunit.async.Async;
	import org.smilkit.events.ViewportEvent;
	import org.smilkit.events.HeartbeatEvent;
	import org.smilkit.time.Heartbeat;
	import org.smilkit.view.Viewport;

	public class HeartbeatTestCase
	{		
		protected var _viewport:Viewport;
		protected var _resumeEventDispatched:Boolean;
		protected var _pauseEventDispatched:Boolean;
		
		[Before]
		public function setUp():void
		{
			this._viewport = new Viewport();
			this._resumeEventDispatched = false;
			this._pauseEventDispatched = false;
			this._viewport.heartbeat.addEventListener(HeartbeatEvent.RESUMED, this.onHeartbeatResumed)
			this._viewport.heartbeat.addEventListener(HeartbeatEvent.PAUSED, this.onHeartbeatPaused)
		}
		
		[After]
		public function tearDown():void
		{
			this._viewport = null;
			this._resumeEventDispatched = false;
			this._pauseEventDispatched = false;
		}
		
		protected function onHeartbeatResumed(event:HeartbeatEvent):void
		{
			this._resumeEventDispatched = true;
		}
		
		protected function onHeartbeatPaused(event:HeartbeatEvent):void
		{
			this._pauseEventDispatched = true;
		}
		
		[Test(description="Tests the resume/pause methods to ensure that a running heartbeat dispatches no resumed event when resumed but does dispatch a paused event when paused")]
		public function pauseProperlyDispatchesPausedEvent():void
		{
			var hb:Heartbeat = this._viewport.heartbeat;
			Assert.assertFalse(hb.running);
			Assert.assertTrue(hb.resume());
			Assert.assertFalse(this._pauseEventDispatched);
			Assert.assertTrue(this._resumeEventDispatched);
			// Reset and assert that resuming a second time dispatches no event
			this._pauseEventDispatched = false;
			this._resumeEventDispatched = false;
			Assert.assertFalse(hb.resume());
			Assert.assertFalse(this._pauseEventDispatched);
			Assert.assertFalse(this._resumeEventDispatched);			
		}
		
		[Test(description="Tests a paused heartbeat to ensure that calling pause dispatches no event but resuming does dispatch a resumed event")]
		public function resumeProperlyDispatchesResumedEvent():void
		{
			var hb:Heartbeat = this._viewport.heartbeat;
			Assert.assertFalse(hb.running);
			// Assert that pausing when paused does nothing
			Assert.assertFalse(hb.pause());
			Assert.assertFalse(this._pauseEventDispatched);
			Assert.assertFalse(this._resumeEventDispatched);
			
			// Resume, then reset
			Assert.assertTrue(hb.resume());
			this._pauseEventDispatched = false;
			this._resumeEventDispatched = false;
			
			// Assert that pausing now returns true and dispatches event
			Assert.assertTrue(hb.pause());
			Assert.assertTrue(this._pauseEventDispatched);
			Assert.assertFalse(this._resumeEventDispatched);
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
			Assert.assertEquals(1, heartBeat.slowBeats);
		}
		
		protected function handleHasSlowBeatsSecondTimeOut(passThroughData:Object):void
		{
			Assert.fail( "Timeout reached before viewport refreshed: HeartbeatTestCase:handleHasSlowBeats");
		}
		
	}
}