package org.smilkit.time
{
	public final class Times
	{
		public static var UNRESOLVED:int = -101;
		public static var MEDIA:int = -102;
		public static var INDEFINITE:int = -103;
		public static var NEGATIVE_INDEFINITE:int = -104;
		
		public static const TIME_MILLISECOND:int = 1;
		public static const TIME_SECOND:int = (Times.TIME_MILLISECOND * 1000);
		public static const TIME_MINUTE:int = (Times.TIME_SECOND * 60);
		public static const TIME_HOUR:int = (Times.TIME_MINUTE * 60);
	}
}