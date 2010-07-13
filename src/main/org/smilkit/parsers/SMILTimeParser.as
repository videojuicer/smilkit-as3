package org.smilkit.parsers
{
	import org.smilkit.dom.smil.Time;
	import org.smilkit.w3c.dom.INode;

	/**
	 * Parses a SMIL time string into a milisecond integer value and clock type.  
	 */
	public class SMILTimeParser
	{
		protected var _parentNode:INode;
		
		protected var _miliseconds:int = 0;
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
		 * The milisecond value of the parsed SMIL time.
		 */
		public function get miliseconds():int
		{
			return this._miliseconds;
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
		
		/**
		 * Parses the specified SMIL time string into the current <code>SMILTimeParser</code>
		 * instance.
		 * 
		 * @param timeString The SMIL time string to parse into miliseconds.
		 */
		public function parse(timeString:String):void
		{
			this._timeString = timeString;
			
			// parse clock values
			if (this._timeString.indexOf(":") != -1)
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
				
				this._miliseconds = ((hours * 60 * 60 * 1000) + (minutes * 60 * 1000) + (seconds * 1000));
				
				this._type = Time.SMIL_TIME_WALLCLOCK;
			}
			else
			{
				// hours
				if (this._timeString.indexOf("h") != -1)
				{
					this._miliseconds = parseInt(this._timeString.substring(0, this._timeString.indexOf("h"))) * 60 * 60 * 1000; 
				}
				// minutes
				else if (this._timeString.indexOf("min") != -1)
				{
					this._miliseconds = parseInt(this._timeString.substring(0, this._timeString.indexOf("min"))) * 60 * 1000; 
				}
				// seconds
				else if (this._timeString.indexOf("s") != -1)
				{
					this._miliseconds = parseInt(this._timeString.substring(0, this._timeString.indexOf("h"))) * 1000; 
				}
				// miliseconds value
				else if (this._timeString.indexOf("ms") != -1)
				{
					this._miliseconds = parseInt(this._timeString.substring(0, this._timeString.indexOf("ms")));
				}
				// assume the time is declared in seconds
				else
				{
					this._miliseconds = parseInt(this._timeString) * 1000;
				}
				
				this._type = Time.SMIL_TIME_OFFSET;
			}
		}
	}
}