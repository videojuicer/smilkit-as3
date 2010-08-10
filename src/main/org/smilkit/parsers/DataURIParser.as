package org.smilkit.parsers
{
	
	import org.utilkit.crypto.Base64;
	import flash.errors.IllegalOperationError;	
	/**
	 * Parses a Data URI, the content of which may be either utf-8 or base64 encoded, and provides
	 * helper methods to access the content type, contained data and other information.
	 */ 
	public class DataURIParser
	{
		
		protected var _uri:String;
		protected var _matches:Array;
		protected var _data:String;
		protected var _rawData:String;
		protected var _contentType:String;
		protected var _charset:String;
		protected var _base64:Boolean;
		
		public function DataURIParser(uri:String)
		{
			this.parse(uri);
		}
		
		public function get uri():String
		{
			return this._uri;
		}
		
		public function get matches():Array
		{
			return this._matches;
		}
		
		public function get data():String
		{
			return this._data;
		}
		
		public function get rawData():String
		{
			return this._rawData;
		}
		
		public function get base64():Boolean
		{
			return this._base64;
		}
		
		public function get contentType():String
		{
			return this._contentType;
		}
		
		public function get charset():String
		{
			return this._charset;
		}
		
		protected function parse(uri:String):void
		{
			// for performance reasons, break out the data fragment first and parse the URI header seperately.
			// no need to run the raw data through a regex.
			
			var uriDataDelimiterIndex:int = uri.indexOf(",");

			if(uriDataDelimiterIndex < 0) throw new IllegalOperationError("Invalid data URI pattern");

			var uriHeader:String = uri.slice(0, uriDataDelimiterIndex);
			var uriData:String = uri.slice(uriDataDelimiterIndex+1, uri.length);
			
			
			// Example:
			// data:[<MIME-type>][;charset="<encoding>"][;base64],<data>
								//    | Data Fragment
								//    |     | Content type
								//    |     |                  | Base64 preflag
								//    |     |                  |         | Charset                  | Base64 postflag
								//    |     |                  |         |                          |         | Data segment
			var dataPattern:RegExp = /^data:([a-z-]+\/[a-z-+]+)(;base64)?(;charset=([0-9A-Za-z-]+))?(base64)?/;
			var matches:Array = uriHeader.match(dataPattern);
			
			if(matches == null) throw new IllegalOperationError("Invalid data URI pattern");
			
			this._uri = uri;
			this._matches = matches;
			
			// Strip contentType
			this._contentType = matches[1];			
			// Strip encoding
			this._charset = matches[4];
			// Base64-encoded?
			if(matches[2] == ";base64" || matches[5] == ";base64") this._base64 = true;
			
			// Stash data
			this._rawData = uriData;
			
			// Decode and store data
			this._data = (this.base64)? Base64.decode(this.rawData) : this.rawData;
		}
		
	}
}