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
		 * A number that indicates the rate at which audio was encoded, in kilobytes per second.
		 */
		public function get audioDataRate():uint
		{
			return this._internalInfo.audiodelay;
		}
		
		/**
		 * A number that indicates what time in the FLV file "time 0" of the original FLV file exists. The video content needs to be delayed by a small amount to properly synchronize the audio.
		 */
		public function get audioDelay():Number
		{
			return this._internalInfo.audiodelay;
		}
		
		/**
		 * A number that indicates the audio codec id (code/decode technique) that was used.
		 */
		public function get audioCodecId():uint
		{
			return this._internalInfo.audiodelay;
		}
		
		/**
		 * A string that indicates the audio codec (code/decode technique) that was used.
		 */
		public function get audioCodec():String
		{
			switch (this.videoCodecId)
			{
				case 0:
					return "Uncompressed";
				case 1:
					return "Adaptive DPCM";
				case 2:
					return "MP3";
				case 5:
					return "Nellymoser 8kHz Mono";
				case 6:
					return "Nellymoser";
				default:
					return "Unknown ("+this.videoCodecId+")";
			}
		}
		
		/**
		 * A Boolean value that is true if the file is encoded with a keyframe on the last frame that allows seeking to the end.of a progressive download movie clip. It is false if the FLV file is not encoded with a keyframe on the last frame.
		 */
		public function get canSeekToEnd():Boolean
		{
			return this._internalInfo.audiodelay;
		}
		
		/**
		 * An array of objects, one for each cue point embedded.
		 */
		public function get cuePoints():Array
		{
			return this._internalInfo.audiodelay;
		}
		
		/**
		 * A number that specifies the duration of the FLV file, in seconds.
		 */
		public function get duration():Number
		{
			return this._internalInfo.duration;
		}
		
		/**
		 * A number that is the frame rate of the FLV file.
		 */
		public function get framerate():Number
		{
			return this._internalInfo.audiodelay;
		}
		
		/**
		 * A number that is the height of the FLV file, in pixels.
		 */
		public function get height():uint
		{
			return this._internalInfo.audiodelay;
		}
		
		/**
		 * A number that is the video data rate of the FLV file.
		 */
		public function get videoDataRate():uint
		{
			return this._internalInfo.audiodelay;
		}
		
		/**
		 * A number that is the codec version that was used to encode the video.
		 */
		public function get videoCodecId():uint
		{
			return this._internalInfo.audiodelay;
		}
		
		/**
		 * A string that is the codec name that was used to encode the video.
		 */
		public function get videoCodec():String
		{
			switch (this.videoCodecId)
			{
				case 2:
					return "H.263";
				case 3:
					return "Screenshare";
				case 4:
					return "VP6";
				case 5:
					return "VP6+A";
				default:
					return "Unknown ("+this.videoCodecId+")";
			}
		}
		
		/**
		 * A number that is the width of the FLV file, in pixels.
		 */
		public function get width():uint
		{
			return this._internalInfo.audiodelay;
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
	}
}