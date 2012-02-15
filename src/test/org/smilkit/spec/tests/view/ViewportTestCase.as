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
package org.smilkit.spec.tests.view
{
	import flash.events.Event;
	
	import flexunit.framework.Assert;
	import flexunit.framework.AsyncTestHelper;
	
	import org.flexunit.async.Async;
	import org.smilkit.events.ViewportEvent;
	import org.smilkit.spec.Fixtures;
	import org.smilkit.view.BaseViewport;
	import org.smilkit.view.Viewport;

	public class ViewportTestCase
	{		
		protected var _viewport:Viewport;
		protected var _viewportWithDocument:Viewport;
		
		protected var _viewportStateLastDispatch:String;
		protected var _muteEventReceived:Boolean;
		protected var _unmuteEventReceived:Boolean;
		protected var _lastVolumeValue:int;
		
		[Before]
		public function setUp():void
		{
			this._muteEventReceived = false;
			this._unmuteEventReceived = false;
			
			this._viewport = new Viewport();
			this._viewport.autoRefresh = false;
			
			this._viewportWithDocument = new Viewport();
			this._viewportWithDocument.addEventListener(ViewportEvent.PLAYBACK_STATE_CHANGED, this.onViewportWithDocumentStateChange);
			this._viewportWithDocument.addEventListener(ViewportEvent.AUDIO_MUTED, this.onViewportWithDocumentMuted);
			this._viewportWithDocument.addEventListener(ViewportEvent.AUDIO_UNMUTED, this.onViewportWithDocumentUnMuted);
			this._viewportWithDocument.addEventListener(ViewportEvent.AUDIO_VOLUME_CHANGED, this.onViewportWithDocumentVolumeChanged);
			this._viewportWithDocument.location = "data:application/smil+xml;charset=utf-8,"+Fixtures.BASIC_SMIL_XML;
		}
		
		[After]
		public function tearDown():void
		{
			this._viewport = null;
			this._lastVolumeValue = -1;
			this._muteEventReceived = false;
			this._unmuteEventReceived = false;
		}
		
		protected function onViewportWithDocumentStateChange(event:ViewportEvent):void
		{
			this._viewportStateLastDispatch = this._viewportWithDocument.playbackState;
		}
		
		protected function onViewportWithDocumentMuted(event:ViewportEvent):void
		{
			this._muteEventReceived = true;
		}
		
		protected function onViewportWithDocumentUnMuted(event:ViewportEvent):void
		{
			this._unmuteEventReceived = true;
		}
		
		protected function onViewportWithDocumentVolumeChanged(event:ViewportEvent):void
		{
			this._lastVolumeValue = this._viewportWithDocument.volume;
		}
		
		[Test(description="Tests that the volume can be set")]
		public function setVolumeWorksAndDispatchesEvents():void
		{
			this._viewportWithDocument.setVolume(70);
			Assert.assertFalse(this._muteEventReceived);
			Assert.assertFalse(this._unmuteEventReceived);
			Assert.assertEquals(70, this._lastVolumeValue);
		}
		
		[Test(description="Tests the setVolume method to ensure that setVolume(0) counts as a mute operation")]
		public function setVolumeToZeroCountsAsMuteOperation():void
		{
			this._viewportWithDocument.setVolume(0);
			Assert.assertTrue(this._muteEventReceived);
			Assert.assertFalse(this._unmuteEventReceived);
			Assert.assertEquals(0, this._lastVolumeValue);
		}
		
		[Test(description="Tests the setVolume method to ensure that increasing the volume from zero counts as an unmute operation")]
		public function changingVolumeFromZeroCountsAsUnmuteOperation():void
		{
			this._viewportWithDocument.mute();
			Assert.assertTrue(this._muteEventReceived);
			Assert.assertFalse(this._unmuteEventReceived);
			
			this._viewportWithDocument.setVolume(70);
			Assert.assertTrue(this._unmuteEventReceived);
		}
		
		[Test(description="Tests the mute method to ensure that unmuting restores to max volume")]
		public function togglingMuteRestoresToMaxIfNoRestorePoint():void
		{
			this._viewportWithDocument.mute();
			Assert.assertEquals(0, this._lastVolumeValue);
			this._viewportWithDocument.unmute();
			Assert.assertEquals(BaseViewport.VOLUME_MAX, this._lastVolumeValue);
		}
		
		[Test(description="Tests the mute and unmute methods to ensure that unmuting with a restore point sets the volume to the value of that restore point")]
		public function togglineMuteRestoresToRestorePoint():void
		{
			this._viewportWithDocument.setVolume(70);
			this._viewportWithDocument.mute(true);
			Assert.assertEquals(0, this._lastVolumeValue);
			this._viewportWithDocument.unmute();
			Assert.assertEquals(70, this._lastVolumeValue);
		}
		
		
		[Test(description="Tests that the viewport is instantiated in a paused state")]
		public function instantiatesInPausedState():void
		{
			Assert.assertEquals(BaseViewport.PLAYBACK_PAUSED, this._viewportWithDocument.playbackState);
		}
		
		[Test(description="Tests the resume() and pause() methods to ensure that the playback state is properly changed.")]
		public function resumeBeginsPlaybackAndPauseStopsPlayback():void
		{
			Assert.assertTrue(this._viewportWithDocument.resume());
			Assert.assertEquals(BaseViewport.PLAYBACK_PLAYING, this._viewportWithDocument.playbackState);
			Assert.assertEquals(BaseViewport.PLAYBACK_PLAYING, this._viewportStateLastDispatch);
			
			Assert.assertFalse(this._viewportWithDocument.resume());
			Assert.assertEquals(BaseViewport.PLAYBACK_PLAYING, this._viewportWithDocument.playbackState);
			Assert.assertEquals(BaseViewport.PLAYBACK_PLAYING, this._viewportStateLastDispatch);
			
			Assert.assertTrue(this._viewportWithDocument.pause());
			Assert.assertEquals(BaseViewport.PLAYBACK_PAUSED, this._viewportWithDocument.playbackState);
			Assert.assertEquals(BaseViewport.PLAYBACK_PAUSED, this._viewportStateLastDispatch);
		}
		
		[Test(description="Tests the seek(offset) method to ensure that it throws the viewport into PLAYBACK_SEEKING state and that it registers a new offset as a state change")]
		public function seekChangesStateAndRegistersANewOffsetAsANewState():void
		{
			Assert.assertEquals(BaseViewport.PLAYBACK_PAUSED, this._viewportWithDocument.playbackState);
			Assert.assertTrue(this._viewportWithDocument.seek(1));
			Assert.assertEquals(BaseViewport.PLAYBACK_SEEKING, this._viewportWithDocument.playbackState);
			Assert.assertEquals(BaseViewport.PLAYBACK_SEEKING, this._viewportStateLastDispatch);
			Assert.assertFalse(this._viewportWithDocument.seek(1));
			Assert.assertTrue(this._viewportWithDocument.seek(2));
			Assert.assertEquals(BaseViewport.PLAYBACK_SEEKING, this._viewportWithDocument.playbackState);
			Assert.assertEquals(BaseViewport.PLAYBACK_SEEKING, this._viewportStateLastDispatch);
		}
		

		[Test(description="Tests the commitSeek() method to ensure that it returns false if no seek is in progress, and otherwise returns true and reverts the playback state.")]
		public function commitSeekRevertsStateIfUncommittedSeekInProgress():void
		{
			// Committing a seek while not in seek state returns false
			Assert.assertTrue(this._viewportWithDocument.resume());
			Assert.assertFalse(this._viewportWithDocument.commitSeek());

			// Committing a seek while in seek state reverts the state to the previously-active state
			Assert.assertTrue(this._viewportWithDocument.seek(1));
			Assert.assertEquals(BaseViewport.PLAYBACK_SEEKING, this._viewportWithDocument.playbackState);
			Assert.assertEquals(BaseViewport.PLAYBACK_SEEKING, this._viewportStateLastDispatch);
			Assert.assertTrue(this._viewportWithDocument.commitSeek());
			Assert.assertEquals(BaseViewport.PLAYBACK_PLAYING, this._viewportWithDocument.playbackState);
			Assert.assertEquals(BaseViewport.PLAYBACK_PLAYING, this._viewportStateLastDispatch);
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
		
		[Test(async,description="Tests that history is remembered correctly when using back and forward")]
		public function historyIsManagedCorrectly():void
		{
			this._viewport.autoRefresh = true;
			
			var listener:Function = Async.asyncHandler(this, this.onViewportRefreshComplete, 5000, { }, this.onViewportRefreshTimeout);
			
			this._viewport.addEventListener(ViewportEvent.REFRESH_COMPLETE, listener);
			
			// ignores #1 because we load #2 to quickly
			this._viewport.location = "http://smilkit.org/1.smil";
			
			this._viewport.location = "http://block4.net/excl.smil";			
		}
		
		protected function onViewportRefreshComplete(e:ViewportEvent, passThru:Object = null):void
		{
			// should be #2
			Assert.assertEquals("http://block4.net/excl.smil", this._viewport.location);
			
			this._viewport.location = "http://smilkit.org/4.smil";
			
			Assert.assertEquals("http://smilkit.org/4.smil", this._viewport.location);
			
			this._viewport.back();
			
			Assert.assertEquals("http://block4.net/excl.smil", this._viewport.location);
		}
		
		protected function onViewportRefreshTimeout(passThru:Object):void
		{
			Assert.fail("Failed whilst waiting for the Viewport to refresh");
		}
		
		[Test(async,description="Can fetch metadata from the document")]
		public function canFetchDocumentMetadata():void
		{
			var asyncListener:Function = Async.asyncHandler(
				this, 
				this.testDocumentMetaDataOnLoad, 
				2000, 
				{}, 
				this.testDocumentMetaDataTimeout);
			
			this._viewport.addEventListener(ViewportEvent.REFRESH_COMPLETE, asyncListener);
			this._viewport.location = "data:text/plain;charset=utf-8,"+Fixtures.METADATA_SMIL_XML;
			this._viewport.refresh();
		}
			protected function testDocumentMetaDataOnLoad(e:ViewportEvent, passthru:Object):void
			{
				Assert.assertNotNull(this._viewport.document);
				Assert.assertEquals("foovalue", this._viewport.getDocumentMeta("fookey"));
				Assert.assertEquals("barvalue", this._viewport.getDocumentMeta("barkey"));
			}
			protected function testDocumentMetaDataTimeout(passthru:Object):void
			{
				Assert.fail("Refresh timeout");
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