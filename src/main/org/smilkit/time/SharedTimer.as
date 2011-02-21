package org.smilkit.time
{
	import flash.utils.Timer;
	
	public final class SharedTimer extends Timer
	{
		public static var DELAY:int = 200;
		
		protected static var __instance:SharedTimer;
		
		public function SharedTimer(blocker:SharedTimerBlocker)
		{
			super(delay, repeatCount);
			
			// start automatically
			super.start();
		}
		
		public override function start():void
		{
			
		}
		
		public override function stop():void
		{
			
		}
		
		public static function get instance():SharedTimer
		{
			if (SharedTimer.__instance == null)
			{
				SharedTimer.__instance = new SharedTimer(new SharedTimerBlocker());
			}
			
			return SharedTimer.__instance;
		}
	}
}

class SharedTimerBlocker { }