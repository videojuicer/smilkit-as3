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
package org.smilkit.handler.state
{
	import flash.display.Sprite;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import org.utilkit.parser.FMSURLParser;

	public class VideoHandlerState extends HandlerState
	{
		protected var _netConnection:NetConnection;
		protected var _netStream:NetStream;
		protected var _video:Video;
		protected var _canvas:Sprite;
		
		protected var _fmsURLParser:FMSURLParser;
		
		public function VideoHandlerState(src:String, handlerOffset:int, netConnection:NetConnection, netStream:NetStream, video:Video, canvas:Sprite)
		{
			super(src, handlerOffset);
			
			this._netConnection = netConnection;
			this._netStream = netStream;
			this._video = video;
			this._canvas = canvas;
		}
		
		public function get netConnection():NetConnection
		{
			return this._netConnection;
		}
		
		public function get netStream():NetStream
		{
			return this._netStream;
		}
		
		public function get fmsURL():FMSURLParser
		{
			if (this._fmsURLParser == null)
			{
				this._fmsURLParser = new FMSURLParser(this.src);
			}
			
			return this._fmsURLParser;
		}
		
		public function get video():Video
		{
			return this._video;
		}
		
		public function get canvas():Sprite
		{
			return this._canvas;
		}
		
		public override function get type():String
		{
			return "video";
		}
		
		public override function compatibleWith(handlerState:HandlerState):Boolean
		{
			if (super.compatibleWith(handlerState))
			{
				if (this.extractedSrc.host == handlerState.extractedSrc.host)
				{
					return true;
				}
			}
			
			return false;
		}
	}
}