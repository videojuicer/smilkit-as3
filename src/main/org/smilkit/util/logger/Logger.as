package org.smilkit.util.logger
{
	import mx.logging.LogLogger;

	public class Logger
	{
		public static function error(message:String, targetObject:Object):void
		{
			Logger.log(message, targetObject, LogLevel.ERROR);
		}
		
		public static function warn(message:String, targetObject:Object):void
		{
			Logger.log(message, targetObject, LogLevel.WARNING);
		}
		
		public static function fatal(message:String, targetObject:Object):void
		{
			Logger.log(message, targetObject, LogLevel.FATAL);
		}
		
		public static function info(message:String, targetObject:Object):void
		{
			Logger.log(message, targetObject, LogLevel.INFORMATION);
		}
		
		public static function debug(message:String, targetObject:Object):void
		{
			Logger.log(message, targetObject, LogLevel.DEBUG);
		}
		
		public static function log(message:String, targetObject:Object, type:String = null):void
		{
			var logMessage:LogMessage = new LogMessage(message, targetObject, type);
			
			// for now;
			trace(logMessage.toString());
		}
	}
}