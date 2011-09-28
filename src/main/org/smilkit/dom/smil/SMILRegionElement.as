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
package org.smilkit.dom.smil
{
	import org.smilkit.render.RegionContainer;
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.smil.ISMILRegionElement;
	
	public class SMILRegionElement extends SMILElement implements ISMILRegionElement
	{
		protected var _regionContainer:RegionContainer;
		
		public function SMILRegionElement(owner:IDocument, name:String = "region")
		{
			super(owner, name);
			
			this._regionContainer = new RegionContainer(this);
		}
		
		public function get regionContainer():RegionContainer
		{
			return this._regionContainer;
		}
		
		public function get fit():String
		{
			return this.getAttribute("fit");
		}
		
		public function set fit(fit:String):void
		{
		}
		
		public function get top():String
		{
			return this.getAttribute("top");
		}
		
		public function set top(top:String):void
		{
		}
		
		public function get bottom():String
		{
			return this.getAttribute("bottom");
		}
		
		public function set bottom(bottom:String):void
		{
		}
		
		public function get left():String
		{
			return this.getAttribute("left");
		}
		
		public function set left(left:String):void
		{
		}
		
		public function get right():String
		{
			return this.getAttribute("right");
		}
		
		public function set right(right:String):void
		{
		}
		
		public function get zIndex():String
		{
			return this.getAttribute("z-index");
		}
		
		public function set zIndex(zIndex:String):void
		{
		}
		
		public function get title():String
		{
			return this.getAttribute("title");
		}
		
		public function set title(title:String):void
		{
		}
		
		public function get backgroundColor():String
		{
			if (this.hasAttribute("backgroundColor"))
			{
				return this.getAttribute("backgroundColor");
			}
			
			return this.getAttribute("background-color");
		}
		
		public function get backgroundOpacity():String
		{
			return this.getAttribute("backgroundOpacity");
		}
		
		public function set backgroundColor(backgroundColor:String):void
		{
		}
		
		public function get height():int
		{
			return (this.getAttribute("height") as int);
		}
		
		public function set height(height:int):void
		{
		}
		
		public function get width():int
		{
			return (this.getAttribute("width") as int);
		}
		
		public function set width(width:int):void
		{
		}
	}
}