package org.smilkit.spec.tests.view
{
	import flash.events.Event;
	
	import flexunit.framework.Assert;
	import flexunit.framework.AsyncTestHelper;
	
	import org.flexunit.async.Async;
	import org.smilkit.events.ViewportEvent;
	import org.smilkit.view.Viewport;

	public class ViewportTestCase
	{		
		protected var _viewport:Viewport;
		
		[Before]
		public function setUp():void
		{
			this._viewport = new Viewport();
			// dont want to actually load
			this._viewport.autoRefresh = false;
		}
		
		[After]
		public function tearDown():void
		{
			this._viewport = null;
		}
		
		// Pending tests:
		// Instantiates with playState == Viewport.PLAYBACK_PAUSED
		[Test(description="Tests that the viewport is instantiated in a paused state")]
		public function instantiatesInPausedState():void
		{
			Assert.assertEquals(Viewport.PLAYBACK_PAUSED, this._viewport.playbackState);
		}
		
		// Resume starts the heartbeat and sets the playState to Viewport.PLAYBACK_PLAYING
		// Pause pauses the heartbeat, maintaining the offset, and sets the playstate to Viewport.PLAYBACK_PAUSED
		// Seeking pauses the heartbeat and sets the offset
		// Seeking while already in a seek state returns true if the offset has changed
		
		// Committing a seek while not in seek state returns false
		// Committing a seek while in seek state reverts the state to the previously-active state
		
		
		[Test(description="Tests the history tracking of the viewport")]
		public function canTrackHistory():void
		{
			this._viewport.location = "http://smilkit.org/one.smil";
			this._viewport.location = "http://smilkit.org/two.smil";
			this._viewport.location = "http://smilkit.org/three.smil";
			
			Assert.assertEquals(3, this._viewport.history.length);
			Assert.assertEquals("http://smilkit.org/three.smil", this._viewport.location);
		}
		
		[Test(description="Tests the navigating the history using the back method")]
		public function canNavigateBackInHistory():void
		{
			this._viewport.location = "http://smilkit.org/one.smil";
			this._viewport.location = "http://smilkit.org/two.smil";
			this._viewport.location = "http://smilkit.org/three.smil";
			
			Assert.assertEquals(3, this._viewport.history.length);
			
			this._viewport.back();
			
			Assert.assertEquals("http://smilkit.org/two.smil", this._viewport.location);
			
			this._viewport.back();
			
			Assert.assertEquals("http://smilkit.org/one.smil", this._viewport.location);
		}
		
		[Test(description="Tests the navigating the history using the forward method")]
		public function canNavigateForwardInHistory():void
		{
			this._viewport.location = "http://smilkit.org/one.smil";
			this._viewport.location = "http://smilkit.org/two.smil";
			this._viewport.location = "http://smilkit.org/three.smil";
			
			Assert.assertEquals(3, this._viewport.history.length);
			
			this._viewport.back();
			this._viewport.back();
			
			Assert.assertEquals("http://smilkit.org/one.smil", this._viewport.location);
			
			this._viewport.forward();
			
			Assert.assertEquals("http://smilkit.org/two.smil", this._viewport.location);
			
			this._viewport.forward();
			
			Assert.assertEquals("http://smilkit.org/three.smil", this._viewport.location);
		}
		
		[Test(async,timeout="3000",description="Tests loading a SMIL document across the network and through the viewport")]
		public function attemptNetworkSMILLoad():void
		{
			this._viewport.autoRefresh = true;
			this._viewport.location = "http://sixty.im/demo.smil";
			//this._viewport.addEventListener(ViewportEvent.REFRESH_COMPLETE, function():void {
			//	Assert.assertNotNull(this._viewport.document);
			//	Assert.assertNotNull(this._viewport.document.getElementById("content"));
			//});	
		}
	}
}