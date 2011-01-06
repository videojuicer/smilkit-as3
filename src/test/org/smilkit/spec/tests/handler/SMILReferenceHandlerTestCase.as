package org.smilkit.spec.tests.handler
{
	import flexunit.framework.Assert;
	
	import org.flexunit.async.Async;
	import org.smilkit.SMILKit;
	import org.smilkit.events.HandlerEvent;
	import org.smilkit.handler.RTMPVideoHandler;
	import org.smilkit.parsers.BostonDOMParser;
	import org.smilkit.spec.Fixtures;
	import org.smilkit.w3c.dom.smil.ISMILDocument;
	import org.smilkit.w3c.dom.smil.ISMILElement;
	import org.smilkit.w3c.dom.smil.ISMILMediaElement;
	
	public class SMILReferenceHandlerTestCase
	{
		protected var _document:ISMILDocument;
		protected var _rtmpElement:ISMILMediaElement;

		[Before]
		public function setUp():void
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			this._document = (parser.parse(Fixtures.MP4_VIDEO_SMIL_XML) as ISMILDocument);
			
			SMILKit.defaults();
			
			//this._rtmpElement = this._document.getElementById("video_rtmp") as ISMILMediaElement;
			//this._rtmpVideoHandler = (SMILKit.createElementHandlerFor(this._rtmpElement) as RTMPVideoHandler);
		}
		
		[After]
		public function tearDown():void
		{
			this._document = null;
			SMILKit.removeHandlers();
		}
		
		[Test(description="Tests to ensure that the handler invalidates its content and loads immediately when the src attribute is modified")]
		public function invalidatesWithImmediateReloadOnSrcAttrModified():void
		{
			
		}
		
		[Test(description="Tests to ensure that the duration of the associated element is unresolved during a reload")]
		public function attachedElementUnresolvedDuringReload():void
		{
			
		}
		
		[Test(description="Ensures that the handler begins loading when first added to the rendertree")]
		public function loadStartedOnFirstRenderTreeAddition():void
		{
			
		}
		
		[Test(description="Ensures that the contents of the external document are added to the document on a successful load")]
		public function documentContentInjectedAfterLoad():void
		{
			
		}
		
		[Test(description="Ensures that the handler's content is invalidated when the handler is removed from the rendertree")]
		public function invalidatedWhenRemovedFromRenderTree():void
		{
			
		}
		
		[Test(description="Ensures that the handler's content is invalidated when the viewport is paused")]
		public function invalidatedWhenViewportPaused():void
		{
			
		}
		
		[Test(description="Ensures that a refresh of the external document removes old content handlers from the loader and the rendertree, and adds the new ones")]
		public function documentHandlersDereferencedOnReload():void
		{
			
		}
	}
}