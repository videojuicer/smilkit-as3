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