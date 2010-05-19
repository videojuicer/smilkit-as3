package org.smilkit.util.logger
{
	/**
	 * LogLevel describes the various levels of log reports, and provides helpers
	 * for conversation.  
	 */
	public class LogLevel
	{
		public static var INFORMATION:String = "logMessageInformation";
		public static var WARNING:String = "logMessageWarning";
		public static var ERROR:String = "logMessageError";
		public static var FATAL:String = "logMessageFatal";
		public static var DEBUG:String = "logMessageDebug";
		
		/**
		 * Returns an integer index for the specified string level.
		 * 
		 * @return Index of the level specified as an integer.
		 */
		public static function indexForLevel(level:String):int
		{
			switch (level)
			{
				case LogLevel.INFORMATION:
					return 1;
					break;
				case LogLevel.WARNING:
					return 2;
					break;
				case LogLevel.ERROR:
					return 3;
					break;
				case LogLevel.FATAL:
					return 4;
					break;
				case LogLevel.DEBUG:
					return 5;
					break;
			}
			
			return 0;
		}
		
		/**
		 * Returns a string for the specified int level.
		 * 
		 * @return String of the level specified.
		 */
		public static function stringForLevel(level:String):String
		{
			switch (level)
			{
				case LogLevel.INFORMATION:
					return "Info";
					break;
				case LogLevel.WARNING:
					return "Warning";
					break;
				case LogLevel.ERROR:
					return "Error";
					break;
				case LogLevel.FATAL:
					return "Fatal";
					break;
				case LogLevel.DEBUG:
					return "Debug";
					break;
			}
			
			return "Unknown";
		}
	}
}