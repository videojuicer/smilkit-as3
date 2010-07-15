package org.smilkit.util.logger.renderers
{
	import flash.errors.IllegalOperationError;
	
	import org.smilkit.util.logger.LogMessage;

	public class LogRenderer
	{
		public function LogRenderer()
		{
			
		}
		
		public function render(message:LogMessage):void
		{
			throw new IllegalOperationError("Render must be overridden by the parent LogRenderer.");
		}
	}
}