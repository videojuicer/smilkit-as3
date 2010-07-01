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
		protected var _viewportWithDocument:Viewport;
		
		protected var _viewportStateLastDispatch:String;
		
		[Before]
		public function setUp():void
		{
			this._viewport = new Viewport();
			// dont want to actually load
			this._viewport.autoRefresh = false;
			this._viewport.addEventListener(ViewportEvent.PLAYBACK_STATE_CHANGED, this.onViewportStateChange);
		}
		
		[After]
		public function tearDown():void
		{
			this._viewport = null;
		}
		
		protected function onViewportStateChange(event:ViewportEvent):void
		{
			this._viewportStateLastDispatch = this._viewport.playbackState;
		}
		
		[Test(description="Tests that the viewport is instantiated in a paused state")]
		public function instantiatesInPausedState():void
		{
			Assert.assertEquals(Viewport.PLAYBACK_PAUSED, this._viewport.playbackState);
		}
		
		[Test(description="Tests the resume() and pause() methods to ensure that the playback state is properly changed.")]
		public function resumeBeginsPlaybackAndPauseStopsPlayback():void
		{
			Assert.assertTrue(this._viewport.resume());
			Assert.assertEquals(Viewport.PLAYBACK_PLAYING, this._viewport.playbackState);
			Assert.assertEquals(Viewport.PLAYBACK_PLAYING, this._viewportStateLastDispatch);
			
			Assert.assertFalse(this._viewport.resume());
			Assert.assertEquals(Viewport.PLAYBACK_PLAYING, this._viewport.playbackState);
			Assert.assertEquals(Viewport.PLAYBACK_PLAYING, this._viewportStateLastDispatch);
			
			Assert.assertTrue(this._viewport.pause());
			Assert.assertEquals(Viewport.PLAYBACK_PAUSED, this._viewport.playbackState);
			Assert.assertEquals(Viewport.PLAYBACK_PAUSED, this._viewportStateLastDispatch);
		}
		
		[Test(description="Tests the seek(offset) method to ensure that it throws the viewport into PLAYBACK_SEEKING state and that it registers a new offset as a state change")]
		public function seekChangesStateAndRegistersANewOffsetAsANewState():void
		{
			Assert.assertEquals(Viewport.PLAYBACK_PAUSED, this._viewport.playbackState);
			Assert.assertTrue(this._viewport.seek(1));
			Assert.assertEquals(Viewport.PLAYBACK_SEEKING, this._viewport.playbackState);
			Assert.assertEquals(Viewport.PLAYBACK_SEEKING, this._viewportStateLastDispatch);
			Assert.assertFalse(this._viewport.seek(1));
			Assert.assertTrue(this._viewport.seek(2));
			Assert.assertEquals(Viewport.PLAYBACK_SEEKING, this._viewport.playbackState);
			Assert.assertEquals(Viewport.PLAYBACK_SEEKING, this._viewportStateLastDispatch);
		}
		

		[Test(description="Tests the commitSeek() method to ensure that it returns false if no seek is in progress, and otherwise returns true and reverts the playback state.")]
		public function commitSeekRevertsStateIfUncommittedSeekInProgress():void
		{
			// Committing a seek while not in seek state returns false
			Assert.assertTrue(this._viewport.resume());
			Assert.assertFalse(this._viewport.commitSeek());

			// Committing a seek while in seek state reverts the state to the previously-active state
			Assert.assertTrue(this._viewport.seek(1));
			Assert.assertEquals(Viewport.PLAYBACK_SEEKING, this._viewport.playbackState);
			Assert.assertEquals(Viewport.PLAYBACK_SEEKING, this._viewportStateLastDispatch);
			Assert.assertTrue(this._viewport.commitSeek());
			Assert.assertEquals(Viewport.PLAYBACK_PLAYING, this._viewport.playbackState);
			Assert.assertEquals(Viewport.PLAYBACK_PLAYING, this._viewportStateLastDispatch);
		}
		
		
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