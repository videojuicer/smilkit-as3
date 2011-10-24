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
package org.smilkit.view
{
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.render.HandlerController;

	// TODO: remove completely
	public dynamic class ViewportObjectPool
	{
		protected var _viewport:Viewport;
		
		/**
		 * Holds the DOM - data Representation of the loaded SMIL XML 
		 */		
		protected var _document:SMILDocument;
		
		/**
		 *  An instance of RenderTree responsible for checking the viewports play position and for controlling the display 
		 */	
		protected var _handlerController:HandlerController;
		
		public function ViewportObjectPool(viewport:Viewport, document:SMILDocument)
		{
			this._viewport = viewport;
			this._document = document;
			
			this.reset();
		}
		
		public function get viewport():Viewport
		{
			return this._viewport;
		}

		public function get document():SMILDocument
		{
			return this._document;
		}
		
		public function get renderTree():HandlerController
		{
			return this._handlerController;
		}
		
		public function reset():void
		{
			// link the object pool to the document
			this._document.viewportObjectPool = this;

			// make the first render tree!
			this._handlerController = new HandlerController(this);
			
			// create render tree to drawingboard
			// drawingboard is always around, and renderTree is constantly destroyed
			// and recreated, so we have to make the link.
			this.viewport.drawingBoard.renderTree = this.renderTree;
		}
	}
}