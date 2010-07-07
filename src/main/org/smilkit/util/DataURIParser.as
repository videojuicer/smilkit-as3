package org.smilkit.util
{
	/**
	 * Parses a Data URI, the content of which may be either utf-8 or base64 encoded, and provides
	 * helper methods to access the content type, contained data and other information.
	 */ 
	public class DataURIParser
	{
		
		protected var _data:String;
		protected var _contentType:String;
		protected var _encoding:String;
		protected var _charset:String;
		
		public function DataURIParser(uri:String)
		{
			this.parse(uri);
		}
		
		public function get data():String
		{
			return this._data;
		}
		
		public function get contentType():String
		{
			return this._contentType;
		}
		
		public function get encoding():String
		{
			return this._encoding;
		}
		
		public function get charset():String
		{
			return this._charset;
		}
		
		protected function parse(uri:String):void
		{
			
		}
		
	}
}