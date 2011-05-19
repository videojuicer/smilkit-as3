package org.smilkit.parsers
{
	import org.smilkit.dom.smil.Time;
	import org.smilkit.w3c.dom.INode;

	/**
	 * Parses a SMIL time string into a millisecond integer value and clock type.  
	 */
	public class SMILTimeParser
	{
		protected var _parentNode:INode;
		
		protected var _milliseconds:int = 0;
		protected var _type:int = Time.SMIL_TIME_OFFSET;
		protected var _timeString:String = null;
		
		public function SMILTimeParser(parentNode:INode, timeString:String = null)
		{
			this._parentNode = parentNode;
			
			if (timeString != null)
			{
				this.parse(timeString);
			}
		}
		
		/**
		 * The millisecond value of the parsed SMIL time.
		 */
		public function get milliseconds():int
		{
			return this._milliseconds;
		}
		
		/**
		 * The type of the parsed SMIL time string, either SMIL_TIME_WALLCLOCK or SMIL_TIME_OFFSET.
		 */
		public function get type():int
		{
			return this._type;
		}
		
		/**
		 * The original SMIL time string that was used to generate the current instance.
		 */
		public function get timeString():String
		{
			return this._timeString;
		}
		
		public function reset():void
		{
			this.parse(null);
		}
		
		public function identifies(timeString:String):Boolean
		{
			if (timeString.indexOf(":") != -1)
			{
				return true;
			}
			
			return (timeString.search(/^(-?)(\d+)(h|ms|s|min)$/i) != -1);
		}
		
		/**
		 * Parses the specified SMIL time string into the current <code>SMILTimeParser</code>
		 * instance.
		 * 
		 * @param timeString The SMIL time string to parse into milliseconds.
		 */
		public function parse(timeString:String):void
		{
			this._timeString = timeString;
			
			if (this._timeString == null || this._timeString == "")
			{
				this._milliseconds = Time.UNRESOLVED;
				this._type = Time.SMIL_TIME_OFFSET;
			}
			// parse clock values
			else if (this._timeString.indexOf(":") != -1)
			{
				var split:Array = this._timeString.split(":");
				
				var hours:uint = 0;
				var minutes:uint = 0;
				var seconds:uint = 0;
				
				// half clock
				if (split.length < 3)
				{
					minutes = uint(split[0]);
					seconds = uint(split[1]);
				}
				// full wall clock
				else
				{
					hours = uint(split[0]);
					minutes = uint(split[1]);
					seconds = uint(split[2]);
				}
				
				this._milliseconds = ((hours * 60 * 60 * 1000) + (minutes * 60 * 1000) + (seconds * 1000));
				
				this._type = Time.SMIL_TIME_WALLCLOCK;
			}
			else
			{
				// hours
				if (this._timeString.indexOf("h") != -1)
				{
					this._milliseconds = parseInt(this._timeString.substring(0, this._timeString.indexOf("h"))) * 60 * 60 * 1000; 
				}
				// minutes
				else if (this._timeString.indexOf("min") != -1)
				{
					this._milliseconds = parseInt(this._timeString.substring(0, this._timeString.indexOf("min"))) * 60 * 1000; 
				}
				// milliseconds value
				else if (this._timeString.indexOf("ms") != -1)
				{
					this._milliseconds = parseInt(this._timeString.substring(0, this._timeString.indexOf("ms")));
				}				
				// seconds
				else if (this._timeString.indexOf("s") != -1)
				{
					this._milliseconds = parseInt(this._timeString.substring(0, this._timeString.indexOf("s"))) * 1000; 
				}
				// assume the time is declared in seconds
				else
				{
					this._milliseconds = parseInt(this._timeString) * 1000;
				}
				
				this._type = Time.SMIL_TIME_OFFSET;
			}
		}
	}
}