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
package org.smilkit.util
{
	import flash.geom.Rectangle;
	
	import org.smilkit.handler.SMILKitHandler;
	import org.smilkit.render.RegionContainer;

	public class MathHelper
	{
		/**
		 * Checks if the specified value is a percentage by checking for 
		 * the % symbol.
		 * 
		 * @param value Value is check.
		 * 
		 * @return True if the value is a percentage, false otherwise.
		 */
		public static function isPercentage(value:*):Boolean
		{
			var s:String = value.toString();
			
			return (s.lastIndexOf("%") != -1);
		}
		
		/**
		 * Converts a percentage number into an integer by removing the trailing %.
		 * 
		 * @param value Value to parse into an integer.
		 * 
		 * @return The integer result of the specified value.
		 */
		public static function percentageToInteger(value:*):uint
		{
			var s:String = value.toString();
			var v:String = s.substr(0, s.indexOf("%"));
			
			return parseInt(v);
		}
		
		/**
		 * Creates a <code>Rectangle</code> <code>Matrix</code> which fits the handler to the parent
		 * region whilst keeping the aspect ration.
		 * 
		 * @param handler The <code>SMILKitHandler</code> to create a <code>Matrix</code> for.
		 * @param region The <code>RegionContainer</code> to fit the handler inside of.
		 * 
		 * @return Generated <code>Rectangle</code> <code>Matrix</code> with the sizes for the handler.
		 */
		public static function createMatrixFor(handler:SMILKitHandler, region:RegionContainer):Rectangle
		{
			// this is where we do the logic for the fitting to a canvas and the like ...
			// think of it like a zombie stretching your brains to fit the region
			var ratio:Number = MathHelper.calculateAspectRatio(handler.width, handler.height);
			var aspectRatio:Number = MathHelper.calculateAspectRatio(region.width, region.height);
			var matrix:Rectangle = new Rectangle();
			
			if (aspectRatio < ratio)
			{
				matrix.width = region.width;
				matrix.height = Math.floor((region.width / handler.width) * handler.height);
				matrix.x = 0;
				matrix.y = ((region.height - matrix.height) / 2);
			}
			else
			{
				matrix.height = region.height;
				matrix.width = Math.floor((region.height / handler.height) * handler.width);
				matrix.y = 0;
				matrix.x = ((region.width - matrix.width) / 2);
			}
			
			return matrix;
		}
		
		public static function calculateAspectRatio(width:Number, height:Number):Number
		{
			return (width / height);
		}
	}
}