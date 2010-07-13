package org.smilkit.parsers
{
	/**
	 * Parses a URL and provides helper properties for access to the different URL pieces.
	 */ 
	public class URLParser
	{
		protected var _url:String;
		
		protected var _host:String = "";
		protected var _port:String = "";
		protected var _protocol:String = "";
		protected var _path:String = "";
		protected var _parameters:Object;
		
		public function URLParser(url:String = null)
		{
			if (url != null)
			{
				this.parse(url);
			}
		}
		
		/**
		 * The original URL passed into the parser.
		 */
		public function get url():String
		{
			return this._url;
		}
		
		public function get hostname():String
		{
			return this.protocol+"://"+this.host+":"+this.port;
		}
		
		/**
		 * The hostname of the parsed URL.
		 */
		public function get host():String
		{
			return this._host;
		}
		
		/**
		 * Port number as a string of the parsed URL.
		 */
		public function get port():String
		{
			return this._port;
		}
		
		/**
		 * The protocol used in the URL.
		 */
		public function get protocol():String
		{
			return this._protocol;
		}
		
		/**
		 * The path defined in the parsed URL.
		 */
		public function get path():String
		{
			return this._path;
		}
		
		/**
		 * The parameters as an <code>Object</code> from the parsed URL.
		 */
		public function get parameters():Object
		{
			return this._parameters;
		}
		
		/**
		 * The file extension used in the parsed URL.
		 */
		public function get extension():String
		{
			var i:int = this.path.lastIndexOf('.');
			
			if (i != -1)
			{
				return this.path.substr(i);
			}
			
			return null;
		}
		
		/**
		 * Parses the specified URL <code>String</code> and populates the <code>URLParser</code>
		 * instance with the extracted data. 
		 * 
		 * @param url The URL <code>String</code> to parse.
		 */
		public function parse(url:String):void
		{
			this._url = url;
			
			var reg:RegExp = /(?P<protocol>[a-zA-Z]+) : \/\/  (?P<host>[^:\/]*) (:(?P<port>\d+))?  ((?P<path>[^?]*))? ((?P<parameters>.*))? /x;
			var results:Array = reg.exec(this._url);
			
			this._protocol = results.protocol;
			this._host = results.host;
			this._port = results.port;
			this._path = results.path;
			
			var params:String = results.parameters;
			
			if (params != "")
			{
				this._parameters = new Object();
				
				if (params.charAt(0) == "?")
				{
					params = params.substring(1);
				}
				
				var parameters:Array = params.split("&");
				
				for each (var s:String in parameters)
				{
					var p:Array = s.split("=");
					
					this._parameters[p[0]] = p[1];
				}
			}
		}
	}
}