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
	import org.smilkit.dom.events.MutationEvent;
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.smil.IElementTimeContainer;
	
	public class ElementBodyTimeContainer extends ElementSequentialTimeContainer
	{
		protected var _intervalsLaunched:Boolean = false;
		
		public function ElementBodyTimeContainer(owner:IDocument, name:String)
		{
			super(owner, name);
			
			this.addEventListener(MutationEvent.DOM_SUBTREE_MODIFIED, this.onDOMBodySubtreeModified, false);
		}
		
		public function get intervalsLaunched():Boolean
		{
			return this._intervalsLaunched;
		}

		public override function get isPlaying():Boolean
		{
			return true;
		}
		
		public override function get parentTimeContainer():ElementTimeContainer
		{
			// return self, theres no time containers above the body
			return this;
		}
		
		public override function gatherFirstInterval():void
		{
			super.gatherFirstInterval();
		}
		
		public override function gatherNextInterval(usingBegin:Time = null):Boolean
		{
			return super.gatherNextInterval(usingBegin);
		}
		
		protected override function childIntervalChanged(child:ElementTimeContainer):void
		{
			// since were our own parent time container, we dont trigger a change when
			// we notify ourself of a new interval
			if (child == this)
			{
				return;
			}

			super.childIntervalChanged(child);
		}
		
		protected function onDOMBodySubtreeModified(e:MutationEvent):void
		{
			this.ownerSMILDocument.scheduler.reset();
			
			this.resetElementState();
			
			this.startup();
			
			this._intervalsLaunched = true;
		}
	}
}