package org.smilkit.spec.mock 
{
	
	import org.smilkit.w3c.dom.IElement;
	import org.smilkit.handler.SMILKitHandler;
	import org.smilkit.events.WorkerEvent;
	import org.smilkit.events.WorkUnitEvent;
	
	public class MockHandler extends SMILKitHandler
	{
		
		public function MockHandler(node:IElement)
		{
			super(node);
		}
		
	}
}