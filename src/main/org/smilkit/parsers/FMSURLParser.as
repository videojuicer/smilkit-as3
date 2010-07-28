package org.smilkit.parsers
{
	public class FMSURLParser extends URLParser
	{
		protected var _useInstance:Boolean = false;
		protected var _applicationName:String;
		protected var _instanceName:String;
		protected var _streamName:String;
		protected var _streamType:String;
		
		protected static const APPLICATION_NAME_INDEX:uint = 0;
		protected static const INSTANCE_NAME_INDEX:uint = 2;
		protected static const STREAM_NAME_INDEX:uint = 4;
		
		protected static const DEFAULT_INSTANCE_NAME:String = "_definst_";
		
		protected static const MP4_STREAM:String = "mp4";
		protected static const ID3_STREAM:String = "id3";
		protected static const MP3_STREAM:String = "mp3";
		protected static const FLV_STREAM:String = "flv";
		
		protected static const QUERY_PARAM_STREAM_NAME:String = "streamName";
		protected static const QUERY_PARAM_STREAM_TYPE:String = "streamType";
		
		public function FMSURLParser(url:String=null)
		{
			super(url);
		}
		
		public function get instanceHostname():String
		{
			var applicationHost:String = this.hostname;
			
			if (this.applicationName != null || this.applicationName != "")
			{
				applicationHost += "/"+this.applicationName;
			}
			
			if (this.instanceName != null || this.instanceName != "")
			{
				applicationHost += "/"+this.instanceName;
			}
			
			return applicationHost;
		}
		
		public function get applicationName():String
		{
			return this._applicationName;
		}
		
		public function get instanceName():String
		{
			return this._instanceName;
		}
		
		public function get streamName():String
		{
			return this._streamName;
		}
		
		public function get streamType():String
		{
			return this._streamType;
		}
		
		public override function parse(url:String):void
		{
			super.parse(url);
		
			this.parsePath();
			this.parseQuery();
		}
			
		protected function parsePath():void
		{
			if (this.path)
			{
				this._streamName = this.getParamValue(FMSURLParser.QUERY_PARAM_STREAM_NAME);
				this._streamType = this.getParamValue(FMSURLParser.QUERY_PARAM_STREAM_TYPE);
			}
			
			var result:Array = this.path.split(/(\/)/);
			
			if (result != null)
			{
				this._applicationName = result[FMSURLParser.APPLICATION_NAME_INDEX];
				this._instanceName = "";
				this._streamName = "";
				
				// are we using an instance?
				if (this.path.search(new RegExp("^.*\/"+FMSURLParser.DEFAULT_INSTANCE_NAME, "i")) > -1)
				{
					this._useInstance = true;
				}
				
				var streamNameIndex:uint = FMSURLParser.STREAM_NAME_INDEX;
				
				if (this._useInstance)
				{
					this._instanceName = result[FMSURLParser.INSTANCE_NAME_INDEX];
				}
				else
				{
					streamNameIndex = FMSURLParser.INSTANCE_NAME_INDEX;
				}
				
				// search for the stream name
				for (var i:uint = streamNameIndex; i < result.length; i++)
				{
					this._streamName += result[i];
				}
				
				if (this._streamName == null || this._streamName == "")
				{
					// check if the stream name is specified in the query params
					this._streamName = this.getParamValue(FMSURLParser.QUERY_PARAM_STREAM_NAME);
				}
				
				// type check
				if (this._streamName.search(/mp4:/i) > -1)
				{
					this._streamType = FMSURLParser.MP4_STREAM;
				}
				else if (this._streamName.search(/id3:/i) > -1)
				{
					this._streamType = FMSURLParser.ID3_STREAM;
				}
				else if (this._streamName.search(/mp3:/i) > -1)
				{
					this._streamType = FMSURLParser.MP3_STREAM;
				}
				else if (this._streamName.search(/flv:/i) > -1)
				{
					this._streamType = FMSURLParser.FLV_STREAM;
				}
				else
				{
					this._streamType = FMSURLParser.FLV_STREAM;
				}
				
				if (this._streamType == null || this._streamType == "")
				{
					// check if the stream type is specified in the query params
					this._streamType = this.getParamValue(FMSURLParser.QUERY_PARAM_STREAM_TYPE);
				}
			}
		}

		protected function parseQuery():void
		{
			
		}
	}
}