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
package org.smilkit.spec.tests.dom
{
	import flexunit.framework.Assert;
	
	import org.flexunit.async.Async;
	import org.smilkit.SMILKit;
	import org.smilkit.dom.smil.time.SMILTimeScheduler;
	import org.smilkit.events.HeartbeatEvent;
	import org.smilkit.events.ViewportEvent;
	import org.smilkit.time.SharedTimer;
	import org.smilkit.view.extensions.SMILViewport;
	import org.utilkit.util.NumberHelper;

	public class SMILTimeSchedulerTestCase
	{
		
		protected var _scheduler:SMILTimeScheduler;
		protected var _resumeEventDispatched:Boolean;
		protected var _pauseEventDispatched:Boolean;
		
		[Before]
		public function setUp():void
		{
			SMILKit.defaults();
			
			this._scheduler = new SMILTimeScheduler(null);
			
			this._resumeEventDispatched = false;
			this._pauseEventDispatched = false;
			
			this._scheduler.addEventListener(HeartbeatEvent.RESUMED, this.onHeartbeatResumed);
			this._scheduler.addEventListener(HeartbeatEvent.PAUSED, this.onHeartbeatPaused);
		}
		
		[After]
		public function tearDown():void
		{
			this._scheduler = null;
			
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
			var hb:SMILTimeScheduler = this._scheduler;
			
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
			var hb:SMILTimeScheduler = this._scheduler;
			
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
		
		
		/*[Test(async, description="Tests that the Hearbeat has an offSet")]
		public function hasOffSet():void
		{
			var asyncHasOffSetCheck:Function = Async.asyncHandler(this, handleHasOffSet, 5000, null, handleHasOffSetTimeOut);
			this._viewport.addEventListener(ViewportEvent.REFRESH_COMPLETE, asyncHasOffSetCheck, false, 0, true);
			this._viewport.location = "http://sixty.im/demo.smil";
		}
		
		protected function handleHasOffSet(event:ViewportEvent, passThroughData:Object):void
		{
			var hb:SMILTimeScheduler = this._viewport.document.scheduler;
			
			//Assert.assertEquals(0, heartBeat.offset);
			
			// will never actually be 0, because the first tick starts from where we last were
			Assert.assertTrue((hb.offset >= 0 && hb.offset <= 2000));
		}
		
		protected function handleHasOffSetTimeOut(passThroughData:Object):void
		{
			Assert.fail( "Timeout reached before viewport refreshed: HeartbeatTestCase:handleHasOffset");
		}*/
	}
}