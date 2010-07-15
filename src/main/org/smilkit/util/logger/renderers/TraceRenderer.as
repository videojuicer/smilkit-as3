package org.smilkit.util.logger.renderers
{
	import org.smilkit.util.logger.LogMessage;

	public class TraceRenderer extends LogRenderer
	{
		public function TraceRenderer()
		{
			super();
		}
		
		public override function render(message:LogMessage):void
		{
			trace(message.toString());
		}
	}
}