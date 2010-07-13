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
			var ratio:Number = (handler.width / handler.height);
			var aspectRatio:Number = (region.width / region.height);
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
	}
}