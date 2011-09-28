/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version 1.1
 * (the "License"); you may not use this file except in compliance with the
 * License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 *
 * The Original Code is the SMILKit library.
 *
 * The Initial Developer of the Original Code is
 * Videojuicer Ltd. (UK Registered Company Number: 05816253).
 * Portions created by the Initial Developer are Copyright (C) 2010
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 * 	Dan Glegg
 * 	Adam Livesley
 *
 * ***** END LICENSE BLOCK ***** */
package org.smilkit.dom.smil.expressions
{
	import org.smilkit.dom.smil.ElementTestContainer;
	import org.smilkit.dom.smil.ElementTimeContainer;
	import org.smilkit.parsers.SMILTimeParser;
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
			if (value is String && this.relatedContainer != null && !SMILTimeParser.identifies(value))
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