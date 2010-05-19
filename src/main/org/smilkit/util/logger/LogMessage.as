package org.smilkit.util.logger
{
	/**
	 * Stores a log message with the associated target object, level and message.
	 */
	public class LogMessage
	{
		protected var _level:String;
		protected var _message:String;
		protected var _targetObject:Object;
		
		public function LogMessage(message:String, targetObject:Object, level:String = null)
		{
			this._message = message;
			
			this._level = level;
			this._targetObject = targetObject;
			
			if ((level == null || level== "") && message.charAt(1) == " ")
			{
				switch (message.charAt(0).toLowerCase())
				{
					case "i":
						this._level = LogLevel.INFORMATION;
						break;
					case "w":
						this._level = LogLevel.WARNING;
						break;
					case "e":
						this._level = LogLevel.ERROR;
						break;
					case "f":
						this._level = LogLevel.FATAL;
						break;
					case "d":
						this._level = LogLevel.DEBUG;
						break;
				}
			}
		}
		
		/**
		 * The level of the <code>LogMessage</code> as a <code>String</code>.
		 */
		public function get level():String
		{
			return this._level;
		}
		
		/**
		 * Target object linked to the <code>LogMessage</code>.
		 */
		public function get targetObject():Object
		{
			return this._targetObject;
		}
		
		/**
		 * Returns the <code>LogMessage</code> as a readable string.
		 * 
		 * @return Readable string of the <code>LogMessage</code>.
		 */
		public function toString():String
		{
			var s:String = "["+LogLevel.stringForLevel(this._level)+"] "+this._message;
			
			if (this._targetObject != null)
			{
				s += " on '"+this._targetObject.toString()+"'";
			}
			
			return s;
		}
	}
}