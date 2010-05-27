package org.smilkit.util
{
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
	}
}