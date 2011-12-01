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
package org.smilkit.util
{
	/**
	 * Metadata class, is used with a video metadata object and provides access to the properties.
	 * 
	 * @see org.smilkit.handler.HTTPVideoHandler
	 */
	public class Metadata
	{
		protected var _internalInfo:Object;
		protected var _syncPoints:Vector.<int> = new Vector.<int>();
		
		protected var _updated:Boolean = false;

		public function Metadata(info:Object)
		{
			this._internalInfo = info;
		}
		
		/**
		 * A number that indicates the number of audio tracks.
		 */
		public function get audioChannels():uint
		{
			return this._internalInfo['audiochannels'];
		}
		
		/**
		 * A number that indicates the rate at which audio was encoded, in kilobytes per second.
		 */
		public function get audioSampleRate():uint
		{
			return this._internalInfo['audiosamplerate'];
		}
		
		/**
		 * A number that indicates what time in the FLV file "time 0" of the original FLV file exists. The video content needs to be delayed by a small amount to properly synchronize the audio.
		 */
		public function get audioDelay():Number
		{
			return this._internalInfo['audiodelay'];
		}
		
		/**
		 * A string that indicates the audio codec id (code/decode technique) that was used.
		 */
		public function get audioCodecId():String
		{			
			return this._internalInfo['audiocodecid'];
		}
		
		/**
		 * A string that indicates the audio codec (code/decode technique) that was used.
		 */
		public function get audioCodec():String
		{
			switch (this.audioCodecId)
			{
				case "mp4a":
					return "AAC";
				default:
					if (this.audioCodecId == null)
					{
						return "NON";
					}
					
					return this.audioCodecId.toUpperCase();
			}
		}
		
		/**
		 * A Boolean value that is true if the file is encoded with a keyframe on the last frame that allows seeking to the end.of a progressive download movie clip. It is false if the FLV file is not encoded with a keyframe on the last frame.
		 */
		public function get canSeekToEnd():Boolean
		{
			return this._internalInfo['canseektoend'];
		}
		
		/**
		 * An array of objects, one for each cue point embedded.
		 */
		public function get cuePoints():Array
		{
			return this._internalInfo['seekpoints'];
		}
		
		/**
		 * Typed vector of the possible sync points in this file, the default
		 * value is an empty <code>Vector</code> not null;
		 */
		public function get syncPoints():Vector.<int>
		{
			if (this._syncPoints == null || (this.cuePoints != null && this._syncPoints.length != this.cuePoints.length))
			{
				this._syncPoints = new Vector.<int>();
				
				if (this.cuePoints != null)
				{
					for (var i:int = 0; i < this.cuePoints.length; i++)
					{
						this._syncPoints.push(this.cuePoints[i].time * 1000);
					}
				}
			}
			
			return this._syncPoints;
		}
		
		/**
		 * A number that specifies the duration of the FLV file, in milliseconds.
		 */
		public function get duration():Number
		{
			return this._internalInfo['duration'] * 1000;
		}
		
		/**
		 * A number that is the frame rate of the FLV file.
		 */
		public function get framerate():Number
		{
			return this._internalInfo['videoframerate'];
		}
		
		/**
		 * A number that is the height of the FLV file, in pixels.
		 */
		public function get height():uint
		{
			return this._internalInfo['height'];
		}

		/**
		 * A number that is the codec version that was used to encode the video.
		 */
		public function get videoCodecId():String
		{
			return this._internalInfo['videocodecid'];
		}
		
		/**
		 * A string that is the codec name that was used to encode the video.
		 */
		public function get videoCodec():String
		{
			switch (this.videoCodecId)
			{
				case "avc1":
					return "H.264";
			}
			
			if (this.videoCodecId == null)
			{
				return "UNKNOWN";
			}
			
			return this.videoCodecId.toUpperCase();
		}
		
		/**
		 * A number that is the width of the FLV file, in pixels.
		 */
		public function get width():uint
		{
			return this._internalInfo['width'];
		}
		
		public function get updated():Boolean
		{
			return this._updated;
		}
		
		/**
		 * Updates the metadata properties available.
		 * 
		 * @param Object The Flash metadata object to update from.
		 */
		public function update(info:Object):void
		{
			for (var key:String in info)
			{
				var value:String = info[key];
				
				if (this._internalInfo[key] != value)
				{
					this._internalInfo[key] = value;
				}
			}
			
			this._updated = true;
		}
		
		/**
		 * Generates a <code>String</code> which includes all the metadata in a nice readable format.
		 * 
		 * @return The created metadata flatten <code>String</code>.
		 */
		public function toString():String
		{
			return "Video: "+this.videoCodec+", "+this.duration+"s, "+this.framerate+"fps, "+this.width+"x"+this.height+". Audio: "+this.audioCodec+", "+this.audioChannels+" channels, "+this.audioSampleRate+" Hz.";
		}
	}
}