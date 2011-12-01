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
package org.smilkit.handler
{
	import flash.events.NetStatusEvent;
	import flash.net.Responder;
	
	import org.smilkit.SMILKit;
	import org.smilkit.util.Metadata;
	import org.smilkit.w3c.dom.IElement;
	
	public class RTMPAudioHandler extends RTMPVideoHandler
	{
		protected var _lengthRequested:Boolean = false;
		
		public function RTMPAudioHandler(element:IElement)
		{
			super(element);
		}
		
		public override function get width():uint
		{
			return super.width;
		}
		
		public override function get height():uint
		{
			return super.height;
		}
		
		public override function get spatial():Boolean
		{
			return false;
		}
		
		protected override function onConnectionNetStatusEvent(e:NetStatusEvent):void
		{
			if (!this._lengthRequested)
			{
				var responder:Responder = new Responder(this.onGetStreamLength, this.onGetStreamLengthStatus);
				
				this._netConnection.call("getStreamLength", responder, this.videoHandlerState.fmsURL.streamNameWithParameters);
				this._lengthRequested = true;
			}
			
			super.onConnectionNetStatusEvent(e);
		}
		
		protected function onGetStreamLength(length:Number):void
		{
			SMILKit.logger.debug("Received RTMP audio stream length: "+length);
			
			var duration:Number = (length * 1000);
			
			this._metadata = new Metadata({
				"audiochannels": 0,
				"audiosamplerate": 0,
				"audiodelay": 0,
				"audiocodecid": 0,
				"canseektoend": 0,
				"seekpoints": 0,
				"duration": duration,
				"videoframerate": 0,
				"height": 0,
				"videocodecid": 0,
				"width": 0
			});
			
			this.resolved(duration);
		}
		
		protected function onGetStreamLengthStatus(info:Object):void
		{
			SMILKit.logger.debug("Stream Status: "+info.toString());
		}
		
		public static function toHandlerMap():HandlerMap
		{
			return new HandlerMap([ 'rtmp', 'rtmpt', 'rtmps', 'rtmpe' ], { 'audio/mp3': [ '.mp3' ] });
		}
	}
}