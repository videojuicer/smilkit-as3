package org.smilkit.dom.smil.display
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import org.smilkit.SMILKit;
	import org.smilkit.dom.smil.ElementTime;
	import org.smilkit.dom.smil.ElementTimeContainer;
	import org.smilkit.events.RenderTreeEvent;
	import org.smilkit.handler.SMILKitHandler;
	
	public class SMILDocumentDisplayStack extends EventDispatcher
	{
		protected var _stack:Vector.<ElementTimeContainer>;
		
		public function SMILDocumentDisplayStack(target:IEventDispatcher = null)
		{
			super(target);
			
			this._stack = new Vector.<ElementTimeContainer>();
		}
		
		public function get elements():Vector.<ElementTimeContainer>
		{
			return this._stack;
		}
		
		public function elementExists(element:ElementTimeContainer):Boolean
		{
			return (this.elements.indexOf(element) >= 0);
		}
		
		public function append(element:ElementTimeContainer):Boolean
		{
			var result:Boolean = false;
			
			if (!this.elementExists(element))
			{
				this.elements.push(element);
				
				result = true;
				
				this.dispatchEvent(new DisplayStackEvent(DisplayStackEvent.ELEMENT_ADDED, element));
			}
			
			SMILKit.logger.benchmark("DISPLAY-STACK->APPEND: "+element+" "+result);
			
			return result;
		}
		
		public function remove(element:ElementTimeContainer):Boolean
		{
			var result:Boolean = false;
			
			if (this.elementExists(element))
			{
				this.elements.splice(this.elements.indexOf(element), 1);
				
				result = true;
				
				this.dispatchEvent(new DisplayStackEvent(DisplayStackEvent.ELEMENT_REMOVED, element));
			}
			
			SMILKit.logger.benchmark("DISPLAY-STACK->REMOVE: "+element+" "+result);
			
			return result;
		}
	}
}