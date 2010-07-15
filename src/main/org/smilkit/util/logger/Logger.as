package org.smilkit.util.logger
{
	import flash.system.Capabilities;
	import flash.system.System;
	
	import org.smilkit.util.logger.renderers.BrowserConsoleRenderer;
	import org.smilkit.util.logger.renderers.LogRenderer;
	import org.smilkit.util.logger.renderers.TraceRenderer;
	
	/**
	 * Provides logging functionality with support for broadcasting via the web browsers error console.
	 */
	public class Logger
	{
		/**
		* A list of LogRenderer instances to which log output should be directed.
		*/
		protected static var _logRenderers:Vector.<LogRenderer>;
		
		public static function set logRenderers(renderers:Vector.<LogRenderer>):void
		{
			Logger._logRenderers = renderers;
		}
		
		public static function get logRenderers():Vector.<LogRenderer>
		{
			return Logger._logRenderers;
		}
		
		public static function addRenderer(renderer:LogRenderer):void
		{
			Logger.removeRenderer(renderer);
			Logger._logRenderers.push(renderer);
		}
		
		public static function removeRenderer(renderer:LogRenderer):void
		{
			var index:uint = Logger._logRenderers.indexOf(renderer);
			if(index > -1)
			{
				Logger._logRenderers.splice(index, 1);
			}
		}
		
		public static function defaultRenderers():void
		{
			Logger._logRenderers = new Vector.<LogRenderer>;
			
			if (Capabilities.isDebugger)
			{
				Logger.logRenderers.push(new TraceRenderer());
			}
			
			Logger.logRenderers.push(new BrowserConsoleRenderer());
		}
		
		/**
		 * Stores and prints the log message as an error.
		 * 
		 * @param message The message <code>String</code>
		 * @param targetObject The target object associated with the log message.
		 */
		public static function error(message:String, targetObject:Object = null):void
		{
			Logger.log(message, targetObject, LogLevel.ERROR);
		}
		
		/**
		 * Stores and prints the log message as a warning.
		 * 
		 * @param message The message <code>String</code>
		 * @param targetObject The target object associated with the log message.
		 */
		public static function warn(message:String, targetObject:Object = null):void
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
		public static function fatal(message:String, targetObject:Object = null):void
		{
			Logger.log(message, targetObject, LogLevel.FATAL);
		}
		
		/**
		 * Stores and prints the log message as an informative message.
		 * 
		 * @param message The message <code>String</code>
		 * @param targetObject The target object associated with the log message.
		 */
		public static function info(message:String, targetObject:Object = null):void
		{
			Logger.log(message, targetObject, LogLevel.INFORMATION);
		}
		
		/**
		 * Stores and prints the log message as a debug message.
		 * 
		 * @param message The message <code>String</code>
		 * @param targetObject The target object associated with the log message.
		 */
		public static function debug(message:String, targetObject:Object = null):void
		{
			Logger.log(message, targetObject, LogLevel.DEBUG);
		}
		
		/**
		 * Create's a snapshot of the memory usage currently being used by SMILKit.
		 * 
		 * @return String Message with the current memory values of Megabytes and Kilobytes.
		 */
		public static function memorySnapshot():String
		{
			var totalMemory:uint = System.totalMemory;
			
			var memoryMB:Number = Math.round(totalMemory / 1024 / 1024 * 100) / 100;
			var memorykB:Number = Math.round(totalMemory / 1024);
			
			return "Memory Snapshot: "+memoryMB+" MB ("+memorykB+" kB)";
		}
		
		/**
		 * Actually stores and prints the log message in the Logger.
		 * 
		 * @param message The message <code>String</code>
		 * @param targetObject The target object associated with the log message.
		 * @param level Level of the log message. 
		 */
		public static function log(message:String, targetObject:Object = null, level:String = null):void
		{
			if(Logger._logRenderers != null)
			{
				var logMessage:LogMessage = new LogMessage(message, targetObject, level);

				// for now;
				for(var i:uint = 0; i < Logger._logRenderers.length; i++)
				{
					var renderer:LogRenderer = Logger._logRenderers[i];
					renderer.render(logMessage);
				}
			}
		}
	}
}