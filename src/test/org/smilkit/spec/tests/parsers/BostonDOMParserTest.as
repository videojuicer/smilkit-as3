package org.smilkit.spec.tests.parsers
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import flexunit.framework.Assert;
	
	import org.flexunit.async.Async;
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.parsers.BostonDOMParser;
	import org.smilkit.w3c.dom.IDocument;

	public class BostonDOMParserTest
	{		
		
		private var _parser:BostonDOMParser
		
		[Before]
		public function setUp():void
		{
			_parser = new BostonDOMParser();
			
		}
		
		[After]
		public function tearDown():void
		{
			_parser = null;
		}
		
		[Test(async, description="tests that the parser can return a document")]
		public function returnsSMILDocument():void
		{
			var asyncSMILDocument:Function = Async.asyncHandler(this, handleSMILDocument, 5000, null, handleSMILDocumentTimeOut);
			var urlRequest:URLRequest = new URLRequest("http://sixty.im/demo.smil");
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, asyncSMILDocument, false, 0, true);
			urlLoader.load(urlRequest);
		}
		
		protected function handleSMILDocument(event:Event, passThroughData:Object):void
		{
			var loader:URLLoader = event.target as URLLoader;
			var document:IDocument = _parser.parse(loader.data.toString());
			Assert.assertTrue(document is SMILDocument)
		}
		
		protected function handleSMILDocumentTimeOut(passThroughData:Object):void
		{
			Assert.fail( "Timeout reached before viewport refreshed: BostonDOMParserTest:SMILDocument");
		}
	}
}