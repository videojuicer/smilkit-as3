package org.smilkit.util
{
	public class Metadata
	{
		protected var _internalInfo:Object;
		
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
			}
			
			return this.audioCodecId.toUpperCase();
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
		 * A number that specifies the duration of the FLV file, in seconds.
		 */
		public function get duration():Number
		{
			return this._internalInfo['duration'];
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
			
			return this.videoCodecId.toUpperCase();
		}
		
		/**
		 * A number that is the width of the FLV file, in pixels.
		 */
		public function get width():uint
		{
			return this._internalInfo['width'];
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
		}
		
		public function toString():String
		{
			return "Video: "+this.videoCodec+", "+this.framerate+"fps, "+this.width+" x "+this.height+". Audio: "+this.audioCodec+", "+this.audioChannels+" channels, "+this.audioSampleRate+" Hz.";
		}
	}
}