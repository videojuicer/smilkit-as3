package org.smilkit.time
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.smilkit.SMILKit;

	/**
	 * Heartbeat controls the timing of the player updates.
	 * 
	 * The Heartbeat instance will automatically adjust the timings of the players 
	 * updates should the player experience any slow down that begins to effect performance
	 *  
	 * 
	 */	
	public class Heartbeat extends Timer
	{
		protected var _timer:Timer;
		protected var _baseline:Date = new Date();
		protected var _offset:Number = 0;
		protected var _slowBeats:int = 0;
		protected var _running:Boolean = false;
		protected var _runningOffset:Number = 0;
		
		public static var BPS_5:Number = 200;
		public static var BPS_2:Number = 500;
		public static var BPS_1:Number = 1000;
		
		public static var SLOW_BEATS_LIMIT:int = 5;
		
		/**
		 * When created HeartBeat creates an event listener to listen to its own timer event
		 * @constructor 
		 * @param delay
		 * 
		 */		
		public function Heartbeat(delay:Number)
		{
			super(delay, 0);
			
			this.addEventListener(TimerEvent.TIMER, this.onTimer, false);
			
			this._baseline = new Date();
			this._offset = 0;
			
			super.start();
		}
		
		/**
		 * The total offset since the Heartbeat was created.
		 */
		public function get offset():Number
		{
			return this._offset;
		}
		
		/**
		 * The running offset, can be paused and resumed sperately away from the
		 * actual offset.
		 */
		public function get runningOffset():Number
		{
			return this._runningOffset;
		}
		
		public function get beatsPerSecond():Number
		{
			return (1000 / this.delay);
		}
		
		public function set beatsPerSecond(value:Number):void
		{
			this.delay = (1000 / value);
		}
		
		/**
		 * The current count of slow beats, a slow beat is counted
		 * when it takes longer to process than the set beat delay.
		 */
		public function get slowBeats():int
		{
			return this._slowBeats;
		}
		
		public override function start():void
		{
			// no starting
		}
		
		public override function stop():void
		{
			// no stopping
		}
		
		public override function reset():void
		{
			this._baseline = new Date();
			this._offset = 0;
			
			super.stop();
			super.reset();
		}
		
		public function resume():void
		{
			this._running = true;
		}
		
		public function pause():void
		{
			this._running = false;
		}
		
		public function seek(offset:Number):void
		{
			this._runningOffset = offset;
		}
		
		protected function onTimer(e:TimerEvent):void
		{
			var delta:Date = new Date();
			var beatDuration:Number = (delta.getTime() - this._baseline.getTime());
			
			if (this.delay < beatDuration)
			{
				// too slow
				this._slowBeats++;
				
				if (this._slowBeats > Heartbeat.SLOW_BEATS_LIMIT && this.delay < 1000)
				{
					// drop bps
				}
			}
			else
			{
				this._slowBeats = 0;
			}
		
			this._offset += beatDuration;
			this._baseline = delta;
			
			if (this._running)
			{
				// we use the beat duration from the overall beat not just the running beat duration, this makes the running offset
				// slightly more responsive but means if a resume happens the actual clock movement wont happen until the next beat.
				// this however should be instant but depends on the delay / speed of the Timer class.
				this._runningOffset += beatDuration;
			}
		}
	}
}