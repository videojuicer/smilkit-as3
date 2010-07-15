package org.smilkit.util.logger.renderers
{
	import flash.external.ExternalInterface;
	
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
						ExternalInterface.call("window['console']['debug']('"+message.toString()+"')");
						break;
					case LogLevel.ERROR:
						ExternalInterface.call("window['console']['error']('"+message.toString()+"')");
						break;
					case LogLevel.FATAL:
						ExternalInterface.call("window['console']['error']('"+message.toString()+"')");
						break;
					case LogLevel.INFORMATION:
						ExternalInterface.call("window['console']['info']('"+message.toString()+"')");
						break;
					case LogLevel.WARNING:
						ExternalInterface.call("window['console']['warn']('"+message.toString()+"')");
						break;
				}
			}
		}
		
		protected function checkForConsole():Boolean
		{
			this._consoleAvailable = false;
			
			if (ExternalInterface.available)
			{
				var console:*;
				
				try
				{
					console = ExternalInterface.call("window['console']");
				}
				catch (e:Error)
				{
					
				}
				finally
				{
					if (console != undefined && console != null)
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