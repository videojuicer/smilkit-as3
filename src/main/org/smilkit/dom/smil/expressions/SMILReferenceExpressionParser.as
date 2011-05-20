package org.smilkit.dom.smil.expressions
{
	import org.smilkit.dom.smil.ElementTestContainer;
	import org.smilkit.dom.smil.ElementTimeContainer;
	import org.smilkit.w3c.dom.IElement;

	public class SMILReferenceExpressionParser extends SMILTimeExpressionParser
	{
		protected var _event:Boolean = false;
		protected var _eventName:String = null;
		protected var _eventTriggered:Boolean = false;
		
		protected var _indefinite:Boolean = false;
		
		protected var _referenced:Boolean = false;
		protected var _referencedBegin:Boolean = false;
		protected var _referencedContainer:ElementTimeContainer = null;
		
		protected var _mediaMarker:String = null;
		
		protected var _resolved:Boolean = false;
		
		public function SMILReferenceExpressionParser(relatedContainer:ElementTestContainer)
		{
			super(relatedContainer);
		}
		
		public function get event():Boolean
		{
			return this._event;
		}
		
		public function get eventName():String
		{
			return this._eventName;
		}
		
		public function get indefinite():Boolean
		{
			return this._indefinite;
		}
		
		public function get resolved():Boolean
		{
			return this._resolved;
		}
		
		public function get referenced():Boolean
		{
			return this._referenced;
		}
		
		public function get referencedBegin():Boolean
		{
			return this._referencedBegin;
		}
		
		public function get referencedContainer():ElementTimeContainer
		{
			return this._referencedContainer;
		}
		
		protected function isEventReference(value:String):Boolean
		{
			return (value.search(/^(activateEvent|beginEvent|endEvent|click|clickEvent)$/i) == 0)
		}
		
		public override function calculateValue(value:Object):Object
		{
			if (value is String && this.relatedContainer != null)
			{
				var str:String = (value as String);
				var identifier:String = null;
				var event:String = null;
				
				if (str.indexOf('.') != -1)
				{
					var split:Array = str.split('.');
					
					identifier = split[0];
					event = split[1];
				}
				else
				{
					identifier = str;
				}
				
				var node:IElement = null;
				
				if (this.isEventReference(identifier))
				{
					// event registered to self
					node = this.relatedContainer;
					event = identifier;
				}
				else
				{
					node = this.relatedContainer.ownerDocument.getElementById(identifier);
				}
				
				if (node != null && node is ElementTestContainer)
				{
					var container:ElementTestContainer = (node as ElementTestContainer);
					
					// references:
					// 	begin
					//  end
					// events
					//	activateEvent
					//  beginEvent
					//	endEvent
					//  click
					
					if (this.isEventReference(event))
					{
						this._event = true;
						this._eventName = event;
						this._referencedContainer = container;
					}
					else
					{
						this._referenced = true;
						this._referencedContainer = container;
						this._referencedBegin = (event == "begin");
					}
					
					return 0;
				}
			}
			
			return super.calculateValue(value);
		}
	}
}