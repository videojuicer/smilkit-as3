/*****************************************************
*  
*  Copyright 2009 Akamai Technologies, Inc.  All Rights Reserved.
*  
*****************************************************
*  The contents of this file are subject to the Mozilla Public License
*  Version 1.1 (the "License"); you may not use this file except in
*  compliance with the License. You may obtain a copy of the License at
*  http://www.mozilla.org/MPL/
*   
*  Software distributed under the License is distributed on an "AS IS"
*  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
*  License for the specific language governing rights and limitations
*  under the License.
*   
*  
*  The Initial Developer of the Original Code is Akamai Technologies, Inc.
*  Portions created by Akamai Technologies, Inc. are Copyright (C) 2009 Akamai 
*  Technologies, Inc. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.smil.model
{
	/**
	 * This class represents a SMIL media element, such
	 * as a video element or an image element.
	 */
	public class SMILMediaElement extends SMILElement
	{
		/**
		 * Constructor.
		 * 
		 * @param type Should be one of the constants defined
		 * in the <code>SMILElementType</code> class.
		 */
		public function SMILMediaElement(type:String)
		{
			super(type);
			
			this._params = new Vector.<SMILAttribute>();
		}

		/**
		 * The media element source. This is typically
		 * a URI/URL pointing to the media.
		 */
		public function get src():String
		{
			return _src;
		}
		
		public function set src(value:String):void
		{
			_src = value;
		}
		
		/**
		 * The media elements's bitrate if applicable, 
		 * specified in kilobits per second (kbps).
		 */
		public function get bitrate():Number
		{
			return _bitrate;
		}
		
		public function set bitrate(value:Number):void
		{
			_bitrate = value;
		}
		
		/**
		 * The duration of the media in seconds if applicable.
		 */
		public function get duration():Number
		{
			return _duration;	
		}
		
		public function set duration(value:Number):void
		{
			_duration = value;	
		}
		
		/** 
		 * Specifies the beginning of a sub-clip in seconds.
		 */
		public function get clipBegin():Number
		{
			return _clipBegin;
		}
		
		public function set clipBegin(value:Number):void
		{
			_clipBegin = value;
		}
		
		/**
		 * Specifies the end of a sub-clip in seconds.
		 */
		public function get clipEnd():Number
		{
			return _clipEnd;
		}
		
		public function set clipEnd(value:Number):void
		{
			_clipEnd = value;
		}
		
		public function get region():String
		{
			return _region;
		}
		
		public function set region(value:String):void
		{
			_region = value;
		}
		
		public function get params():Vector.<SMILAttribute>
		{
			return _params;
		}
		
		public function addParam(name:String, value:String):void
		{
			var param:SMILAttribute = new SMILAttribute();
			param.name = name;
			param.value = value;
			
			this.params.push(param);
		}
		
		public function getParamByName(name:String):SMILAttribute
		{
			for (var i:uint = 0; i < this.params.length; i++)
			{
				var param:SMILAttribute = this.params[i];
				
				if (param.name == name)
				{
					return param;
				}
			}
			
			return null;
		}
		
		private var _src:String;
		private var _bitrate:Number;
		private var _duration:Number;
		private var _clipBegin:Number;
		private var _clipEnd:Number;
		private var _region:String;
		private var _params:Vector.<SMILAttribute>;
	}
}
