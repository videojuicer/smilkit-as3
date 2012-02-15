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
	import org.smilkit.time.Times;
	import org.smilkit.w3c.dom.IDocument;
	import org.smilkit.w3c.dom.smil.IElementSequentialTimeContainer;
	import org.smilkit.w3c.dom.smil.ISMILRefElement;
	
	public class SMILRefElement extends SMILMediaElement implements ISMILRefElement, IElementSequentialTimeContainer
	{
		public function SMILRefElement(owner:IDocument, name:String)
		{
			super(owner, name);
		}

		public override function get durationResolved():Boolean
		{
			if (super.durationResolved)
			{
				return true;
			}
			
			if (this.timeDescendants.length == 0)
			{
				return false;
			}
			
			for (var i:int = (this.timeDescendants.length-1); i >= 0; i--)
			{
				if (this.timeDescendants.item(i) is ElementTimeContainer)
				{
					if(!(this.timeDescendants.item(i) as ElementTimeContainer).durationResolved)
					{
						return false;
					}
				}
			}
			return true;
		}
		
		public override function get duration():Number
		{
			var duration:Number = super.duration;
			
			if (this.hasChildNodes() && (duration == Times.MEDIA && !this.hasDuration())) // counts special constants like UNRESOLVED
			{
				var childDuration:Number = 0;
				
				for (var i:int = 0; i < this.timeDescendants.length; i++)
				{
					if (this.timeDescendants.item(i) is ElementTimeContainer)
					{
						var container:ElementTimeContainer = (this.timeDescendants.item(i) as ElementTimeContainer);
						//container.resolve();
						
						//if (!(container.end as TimeList).resolved)
						//{
						//	return Times.UNRESOLVED;
						//}
						
						if (container.end.first.resolvedOffset > childDuration)
						{
							childDuration = container.end.first.resolvedOffset;
						}
					}
				}
				
				if (childDuration != 0)
				{
					childDuration = (childDuration - this.begin.first.resolvedOffset);
					
					return childDuration;
				}
				
				return Times.MEDIA;
			}
			
			return duration;
		}
	}
}