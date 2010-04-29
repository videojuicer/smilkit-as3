package org.smilkit.spec.tests.handler
{
	import org.smilkit.SMILKit;
	import org.smilkit.handler.HTTPVideoHandler;
	import org.smilkit.parsers.BostonDOMParser;
	import org.smilkit.spec.Fixtures;
	import org.smilkit.w3c.dom.smil.ISMILDocument;
	import org.smilkit.w3c.dom.smil.ISMILElement;
	import org.smilkit.w3c.dom.smil.ISMILMediaElement;

	public class HTTPVideoHandlerTestCase
	{		
		protected var _document:ISMILDocument;
		protected var _httpElement:ISMILMediaElement;
		protected var _httpVideoHandler:HTTPVideoHandler;
		
		[Before]
		public function setUp():void
		{
			var parser:BostonDOMParser = new BostonDOMParser();
			this._document = (parser.parse(Fixtures.MP4_VIDEO_SMIL_XML) as ISMILDocument);
			
			SMILKit.defaultHandlers();
			
			this._httpElement = this._document.getElementById("video_http") as ISMILMediaElement;
			this._httpVideoHandler = (SMILKit.createElementHandlerFor(this._httpElement) as HTTPVideoHandler);
		}
		
		[After]
		public function tearDown():void
		{
			this._document = null;
			
			SMILKit.removeHandlers();
		}
		
		[Test(descriptions="Tests loading a http video")]
		public function canLoadAVideo():void
		{
			this._httpVideoHandler.load();
		}
	}
}