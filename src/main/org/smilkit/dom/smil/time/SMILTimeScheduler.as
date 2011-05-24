package org.smilkit.dom.smil.time
{
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.events.HeartbeatEvent;
	import org.smilkit.time.SharedTimer;
	import org.utilkit.collection.Hashtable;

	public class SMILTimeScheduler extends EventDispatcher
	{
		protected var _ownerSMILDocument:SMILDocument;
		
		protected var _running:Boolean = false;
		
		protected var _baseLine:Date = null;
		protected var _uptime:Number = 0;
		protected var _offset:Number = 0;
		
		protected var _waitingCallbacks:Hashtable;
		
		public function SMILTimeScheduler(ownerDocument:SMILDocument)
		{
			this._ownerSMILDocument = ownerDocument;
			
			this.reset();
			
			SharedTimer.instance.addEventListener(TimerEvent.TIMER, this.onTimerTick);
		}
		
		public function get running():Boolean
		{
			return this._running;
		}
		
		/**
		 * Total number of milliseconds past since the SMILTimeScheduler was created.
		 */
		public function get uptime():Number
		{
			return this._uptime;
		}
		
		/**
		 * Running offset in milliseconds, changes dynamically with the current state
		 * of the scheduler. Because the scheduler can be seeked, paused or resumed
		 * the offset can change drastically and does not necessarily follow a logical
		 * step.
		 */
		public function get offset():Number
		{
			return this._offset;
		}
		
		/**
		 * The SMILDocument instance that owns this scheduler instance.
		 */
		protected function get ownerSMILDocument():SMILDocument
		{
			return this._ownerSMILDocument;
		}
		
		/**
		 * Resumes the heartbeat and changes the running state to true.
		 *
		 * @return True if the resume was successful, false otherwise.
		 */ 
		public function resume():Boolean
		{
			if (!this.running)
			{
				this._running = true;
				
				this.dispatchEvent(new HeartbeatEvent(HeartbeatEvent.RESUMED, this.offset));
				
				this.triggerTickNow();
				
				return true;
			}
			
			return false;
		}
		
		/**
		 * Pauses the heartbeat and changes the running state to false.
		 *
		 * @return True if the pause was successful, false otherwise.
		 */ 
		public function pause():Boolean
		{
			if (this.running)
			{
				this._running = false;
				
				this.dispatchEvent(new HeartbeatEvent(HeartbeatEvent.PAUSED, this.offset));
				
				return true;
			}
			
			return false;
		}
		
		public function seek(offset:Number):void
		{
			this._baseLine = new Date();
			this._offset = offset;
			
			this.triggerTickNow();
		}
		
		public function reset():void
		{
			this._baseLine = new Date();
			
			this._uptime = 0;
			this._offset = 0;
			
			this._waitingCallbacks = new Hashtable();
		}
		
		public function waitUntil(offset:Number, callback:Function):Boolean
		{			
			if (offset >= this.ownerSMILDocument.offset)
			{
				if (!this._waitingCallbacks.hasItem(offset))
				{
					this._waitingCallbacks.setItem(offset, new Vector.<Function>());
				}
				
				(this._waitingCallbacks.getItem(offset) as Vector.<Function>).push(callback);
				
				return true;
			}
			
			// already happened
			return false;
		}
		
		public function removeWaitUntil(callback:Function):void
		{
			for (var i:uint = 0; i < this._waitingCallbacks.length; i++)
			{
				var offset:Number = (this._waitingCallbacks.getKeyAt(i) as Number);
				var callbacks:Vector.<Function> = (this._waitingCallbacks.getItemAt(i) as Vector.<Function>);
				
				if (callbacks != null)
				{
					var newCallbacks:Vector.<Function> = new Vector.<Function>();
					
					for (var k:uint = 0; k < callbacks.length; k++)
					{
						if (callbacks[k] != callback)
						{
							newCallbacks.push(callbacks[k]);
						}
					}
					
					this._waitingCallbacks.setItemAt(newCallbacks, i);
				}
			}
		}
		
		protected function triggerTickNow():void
		{
			var delta:Date = new Date();
			var duration:Number = (delta.getTime() - this._baseLine.getTime());
			
			this._uptime += duration;
			this._baseLine = delta;
			
			if (this.running)
			{
				this._offset += duration;

				this.dispatchEvent(new HeartbeatEvent(HeartbeatEvent.RUNNING_OFFSET_CHANGED, this._offset));
			}
			
			for (var i:uint = 0; i < this._waitingCallbacks.length; i++)
			{
				var offset:Number = (this._waitingCallbacks.getKeyAt(i) as Number);
				
				if (Math.abs(this.offset - offset) < SharedTimer.DELAY)
				{
					var callbacks:Vector.<Function> = (this._waitingCallbacks.getItemAt(i) as Vector.<Function>);
					
					for (var k:uint = 0; k < callbacks.length; k++)
					{
						callbacks[k].call();
					}
				}
			}
		}
		
		protected function onTimerTick(e:TimerEvent):void
		{	
			this.triggerTickNow();
			
			// why send out the tick event here when you can use SharedTime.addEventListener
		}
	}
}