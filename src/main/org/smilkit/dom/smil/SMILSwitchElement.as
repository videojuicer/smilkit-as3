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
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.IElement;
	import org.smilkit.w3c.dom.INode;
	import org.smilkit.w3c.dom.smil.ISMILSwitchElement;
	
	public class SMILSwitchElement extends ElementParallelTimeContainer implements ISMILSwitchElement
	{
		public function SMILSwitchElement(owner:IDocument, name:String)
		{
			super(owner, name);
		}
		
		public override function get durationResolved():Boolean
		{
			var selected:IElement = this.selectedElement;
			
			if (selected != null)
			{
				return (selected as ElementTimeContainer).durationResolved;
			}
			
			return true;
		}
		
		public override function get duration():Number
		{
			var selected:ElementTimeContainer = (this.selectedElement as ElementTimeContainer);
			
			if (selected != null)
			{
				//selected.resolve();
				
				return selected.duration;
			}
			
			return 0;
		}
		
		public function get selectedElement():IElement
		{
			var selected:INode = null;
			var child:INode = this.firstChild;
			
			while ((child = child.nextSibling) != null)
			{
				// test child
				if (child is ElementTestContainer)
				{
					if ((child as ElementTestContainer).test())
					{
						selected = child
						
						break;
					}
				}
			}
			
			return (selected as IElement);
		}
		
		public override function resumeElement():void
		{
			// only resume the selected element
			if (this.selectedElement != null)
			{
				this.resumeElement();
			}
			
			this._playbackState = ElementTimeContainer.PLAYBACK_STATE_PLAYING;
		}
		
		public override function computeImplicitDuration():Time
		{
			// no duration defined on a par, so we use the children
			var selected:ElementTimeContainer = (this.selectedElement as ElementTimeContainer);
			
			if (selected != null)
			{
				if (selected.currentEndInterval != null)
				{
					return new Time(this, false, (selected.currentEndInterval.resolvedOffset * 1000)+"ms");
				}
			}
			
			return new Time(this, false, "unresolved");
		}
	}
}