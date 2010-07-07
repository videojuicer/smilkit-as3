package org.smilkit.spec.tests.util
{
	import flash.events.Event;
	
	import flexunit.framework.Assert;
	import flexunit.framework.AsyncTestHelper;
	import org.flexunit.async.Async;
	
	import org.smilkit.util.DataURIParser;

	public class DataURIParserTestCase
	{		
		
		protected var _utf8uri:String;
		protected var _base64uri:String;
		
		[Before]
		public function setUp():void
		{
			// All data values are "<ABCDEFG> for testing purposes"
			this._utf8uri = "data:text/plain;charset=utf-8,<ABCDEFG>";
			this._base64uri = "data:text/html;base64,PEFCQ0RFRkc+"
		}
		
		[After]
		public function tearDown():void
		{
			this._utf8uri = null;
			this._base64uri = null;
		}
		
		[Test(description="Tests parsing of a UTF-8 encoded data URI and ensures that all properties are read correctly.")]
		public function dataURIwithUTF8dataParsedCorrectly():void
		{
			var parser:DataURIParser = new DataURIParser(this._utf8uri);
		}
		
		[Test(description="Tests parsing of a Base64 encoded data URI and ensures that all properties are read correctly.")]
		public function dataURIwithBase64dataParsedCorrectly():void
		{
			var parser:DataURIParser = new DataURIParser(this._base64uri);
		}
	}
}