package org.smilkit.util.logger
{
	/**
	 * Provides logging functionality with support for broadcasting via the web browsers error console.
	 */
	public class Logger
	{
		/**
		 * Stores and prints the log message as an error.
		 * 
		 * @param message The message <code>String</code>
		 * @param targetObject The target object associated with the log message.
		 */
		public static function error(message:String, targetObject:Object):void
		{
			Logger.log(message, targetObject, LogLevel.ERROR);
		}
		
		/**
		 * Stores and prints the log message as a warning.
		 * 
		 * @param message The message <code>String</code>
		 * @param targetObject The target object associated with the log message.
		 */
		public static function warn(message:String, targetObject:Object):void
		{
			Logger.log(message, targetObject, LogLevel.WARNING);
		}
		
		/**
		 * Stores and prints the log message as a fatal error, a fatal error
		 * defines an error that stops the usual functionality.
		 * 
		 * @param message The message <code>String</code>
		 * @param targetObject The target object associated with the log message.
		 */
		public static function fatal(message:String, targetObject:Object):void
		{
			Logger.log(message, targetObject, LogLevel.FATAL);
		}
		
		/**
		 * Stores and prints the log message as an informative message.
		 * 
		 * @param message The message <code>String</code>
		 * @param targetObject The target object associated with the log message.
		 */
		public static function info(message:String, targetObject:Object):void
		{
			Logger.log(message, targetObject, LogLevel.INFORMATION);
		}
		
		/**
		 * Stores and prints the log message as a debug message.
		 * 
		 * @param message The message <code>String</code>
		 * @param targetObject The target object associated with the log message.
		 */
		public static function debug(message:String, targetObject:Object):void
		{
			Logger.log(message, targetObject, LogLevel.DEBUG);
		}
		
		/**
		 * Actually stores and prints the log message in the Logger.
		 * 
		 * @param message The message <code>String</code>
		 * @param targetObject The target object associated with the log message.
		 * @param level Level of the log message 
		 */
		public static function log(message:String, targetObject:Object, level:String = null):void
		{
			var logMessage:LogMessage = new LogMessage(message, targetObject, level);
			
			// for now;
			trace(logMessage.toString());
		}
	}
}