package org.smilkit.util.logger.renderers
{
	import flash.external.ExternalInterface;
	import flash.system.Capabilities;
	
	import org.smilkit.util.logger.LogLevel;
	import org.smilkit.util.logger.LogMessage;

	public class BrowserConsoleRenderer extends LogRenderer
	{
		protected var _consoleAvailable:Boolean = false;
		protected var _consoleChecked:Boolean = false;
		
		public function BrowserConsoleRenderer()
		{
			super();
		}
		
		public override function render(message:LogMessage):void
		{
			if (!this._consoleChecked)
			{
				this.checkForConsole();
			}
			
			if (this._consoleAvailable)
			{
				switch (message.level)
				{
					case LogLevel.DEBUG:
						ExternalInterface.call("console.debug", message.toString());
						break;
					case LogLevel.ERROR:
						ExternalInterface.call("console.error", message.toString());
						break;
					case LogLevel.FATAL:
						ExternalInterface.call("console.error", message.toString());
						break;
					case LogLevel.INFORMATION:
						ExternalInterface.call("console.info", message.toString());
						break;
					case LogLevel.WARNING:
						ExternalInterface.call("console.warn", message.toString());
						break;
					default:
						ExternalInterface.call("console.log", message.toString());
						break;
				}
			}
		}
		
		protected function checkForConsole():Boolean
		{
			var playerType:String = Capabilities.playerType.toLowerCase();
			var browserAvailable:Boolean = (playerType == "plugin" || playerType == "activex");
			
			this._consoleAvailable = false;
			
			if (browserAvailable && ExternalInterface.available)
			{
				var consoleAvailable:Boolean = false;
				
				try
				{
					consoleAvailable = ExternalInterface.call("function(){ return typeof window.console == 'object' && (typeof console.info == 'function' || typeof console.info == 'object'); }");
				}
				catch (e:Error)
				{
					
				}
				finally
				{
					if (consoleAvailable)
					{
						this._consoleAvailable = true;
					}
				}
			}
			
			this._consoleChecked = true;
			
			return this._consoleAvailable;
		}
	}
}