package org.smilkit.util
{
	import flash.geom.Rectangle;
	
	import org.smilkit.handler.SMILKitHandler;
	import org.smilkit.render.RegionContainer;

	public class MathHelper
	{
		public static function isPercentage(value:*):Boolean
		{
			var s:String = value.toString();
			
			return (s.lastIndexOf("%") != -1);
		}
		
		public static function percentageToInteger(value:*):uint
		{
			var s:String = value.toString();
			var v:String = s.substr(0, s.indexOf("%"));
			
			return parseInt(v);
		}
		
		public static function createMatrixFor(handler:SMILKitHandler, region:RegionContainer):Rectangle
		{
			// this is where we do the logic for the fitting to a canvas and the like ...
			// think of it like a zombie stretching your brains to fit the region
			var ratio:Number = (handler.intrinsicWidth / handler.intrinsicHeight);
			var aspectRatio:Number = (region.width / region.height);
			var matrix:Rectangle = new Rectangle();
			
			if (aspectRatio < ratio)
			{
				matrix.width = region.width;
				matrix.height = Math.floor((region.width / handler.intrinsicWidth) * handler.intrinsicHeight);
				matrix.x = 0;
				matrix.y = ((region.height - matrix.height) / 2);
			}
			else
			{
				matrix.height = region.height;
				matrix.width = Math.floor((region.height / handler.intrinsicHeight) * handler.intrinsicWidth);
				matrix.y = 0;
				matrix.x = ((region.width - matrix.width) / 2);
			}
			
			return matrix;
		}
	}
}