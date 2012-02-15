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
package org.smilkit.dom.smil.time
{
	import flash.events.EventDispatcher;
	
	import org.smilkit.SMILKit;
	import org.smilkit.dom.smil.ElementBodyTimeContainer;
	import org.smilkit.dom.smil.ElementTimeContainer;
	import org.smilkit.dom.smil.SMILDocument;
	import org.smilkit.events.HeartbeatEvent;
	import org.smilkit.time.SharedTimer;
	import org.utilkit.collection.Hashtable;

	public class SMILTimeScheduler extends EventDispatcher
	{
		protected var _ownerSMILDocument:SMILDocument;
		
		protected var _running:Boolean = false;
		protected var _userPaused:Boolean = false;
		
		protected var _baseLine:Date = null;
		protected var _offset:Number = 0;
		
		protected var _uptime:Number = 0;
		protected var _runningUptime:Number = 0;
		
		protected var _lastDuration:Number = 0;
		
		protected var _waitingCallbacks:Hashtable;
		
		protected var _everyCallbacks:Hashtable = new Hashtable();
		protected var _everyRunningCallbacks:Hashtable = new Hashtable();
		
		public function SMILTimeScheduler(ownerDocument:SMILDocument)
		{
			this._ownerSMILDocument = ownerDocument;
			
			this.reset();
			
			SharedTimer.subscribe(this.onTimerTick);
		}
		
		public function get isRealTime():Boolean
		{
			return true;
		}
		
		public function get lastDuration():Number
		{
			return this._lastDuration;
		}
		
		public function get running():Boolean
		{
			return this._running;
		}
		
		public function get userPaused():Boolean
		{
			return this._userPaused;
		}
		
		/**
		 * Total number of milliseconds past since the SMILTimeScheduler was created.
		 */
		public function get uptime():Number
		{
			return this._uptime;
		}
		
		public function get runningUptime():Number
		{
			return this._runningUptime;
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
			if (!this.isRealTime)
			{
				SMILKit.logger.warn("FATAL: Heartbeat is not set to run with real time, freezes to the virtual machine will suspend the clock.");
			}
			
			this._userPaused = false;
			
			if (!this.running)
			{
				SMILKit.logger.debug("Scheduler resumed with a current offset of "+this.offset+"s");
				
				this._running = true;
				
				this.dispatchEvent(new HeartbeatEvent(HeartbeatEvent.RESUMED, this.offset));
				
				this._baseLine = new Date();
				
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
				SMILKit.logger.debug("Scheduler paused with a current offset of "+this.offset+"s");
				
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
			
			if (this.ownerSMILDocument != null)
			{
				var bodyContainer:ElementBodyTimeContainer = (this.ownerSMILDocument.getElementsByTagName("body").item(0) as ElementBodyTimeContainer);
				
				if (bodyContainer != null)
				{
					//bodyContainer.resetElementState();
					//bodyContainer.startup();
					
					bodyContainer.seekElement(offset / 1000);
				}
			}
			
			this.triggerTickNow();
			this.triggerRunningTickNow();
		}
		
		public function reset():void
		{
			if (this._waitingCallbacks != null)
			{
				SMILKit.logger.debug("Scheduler reset, all "+this._waitingCallbacks.length+" waiting callbacks have been purged.");
			}
			
			this._baseLine = new Date();
			
			this._userPaused = false;
			
			this._uptime = 0;
			this._runningUptime = 0;
			
			this._offset = 0;
			
			this._waitingCallbacks = new Hashtable();
			
			this._running = true;
			
			this.triggerTickNow();
			
			this._running = false;
		}
		
		public function userResume():void
		{
			this.resume();
		}
		
		public function userPause():void
		{
			this._userPaused = true;
			
			this.pause();
		}
		
		public function waitUntil(offset:Number, callback:Function, element:ElementTimeContainer = null, friendlyName:String = null):Boolean
		{
			if ((offset * 1000) >= this.offset)
			{
				var callbacks:Vector.<Function> = null;
				
				if (!this._waitingCallbacks.hasItem(offset))
				{
					callbacks = new Vector.<Function>();
					
					this._waitingCallbacks.setItem(offset, callbacks);
				}
				else
				{
					callbacks = (this._waitingCallbacks.getItem(offset) as Vector.<Function>);
				}
				
				if (callbacks.indexOf(callback) == -1)
				{
					SMILKit.logger.debug("Scheduler added callback named "+friendlyName+" at "+offset+"s, from "+element);
					
					callbacks.push(callback);
				}
					
				return true;
			}
			
			// already happened
			return false;
		}
		
		public function removeWaitUntil(callback:Function, element:ElementTimeContainer = null, friendlyName:String = null):void
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
					
					//SMILKit.logger.debug("Scheduler removed callback named "+friendlyName+" at "+offset+"s, from "+element);
				}
			}
		}
		
		public function every(seconds:Number, callback:Function, whenRunning:Boolean = false):void
		{
			var callbacks:Vector.<Function> = null;
			
			if (whenRunning)
			{
				if (!this._everyRunningCallbacks.hasItem(seconds))
				{
					callbacks = new Vector.<Function>();
					
					this._everyRunningCallbacks.setItem(seconds, callbacks);
				}
				else
				{
					callbacks = (this._everyRunningCallbacks.getItem(seconds) as Vector.<Function>);
				}
			}
			else
			{
				if (!this._everyCallbacks.hasItem(seconds))
				{
					callbacks = new Vector.<Function>();
					
					this._everyCallbacks.setItem(seconds, callbacks);
				}
				else
				{
					callbacks = (this._everyCallbacks.getItem(seconds) as Vector.<Function>);
				}
			}
			
			if (callbacks.indexOf(callback) == -1)
			{
				SMILKit.logger.debug("Scheduler added every callback for every "+seconds+"s, running "+whenRunning);
				
				callbacks.push(callback);
			}
		}
		
		public function removeEvery(seconds:Number, callback:Function, whenRunning:Boolean = false):void
		{
			if (whenRunning)
			{
				
			}
		}
		
		public function triggerTickNow():void
		{
			var delta:Date = new Date();
			var duration:Number = (delta.getTime() - this._baseLine.getTime());
			
			if (!this.isRealTime)
			{
				duration = SharedTimer.DELAY;
			}
			
			this._uptime += duration;
			this._baseLine = delta;
			
			this._lastDuration = duration;
			
			if (this._everyCallbacks != null)
			{
				var everyCallbacksTriggered:uint = 0;
				
				for (var j:uint = 0; j < this._everyCallbacks.length; j++)
				{
					var seconds:Number = (this._everyCallbacks.getKeyAt(j) as Number);
					var ms:Number = (seconds * 1000);
					
					if ((this.uptime % ms) < SharedTimer.DELAY)
					{
						var everyCallbacks:Vector.<Function> = (this._everyCallbacks.getItemAt(j) as Vector.<Function>);
						
						for (var o:int = (everyCallbacks.length - 1); o >= 0; o--)
						{
							everyCallbacks[o].call();
							
							everyCallbacksTriggered++;
						}
					}
				}
			}
			
			if (this.running)
			{
				this._offset += duration;
				this._runningUptime += duration;

				this.dispatchEvent(new HeartbeatEvent(HeartbeatEvent.RUNNING_OFFSET_CHANGED, this._offset));
				
				this.triggerRunningTickNow();
			}
		}
		
		protected function triggerRunningTickNow():void
		{
			var callbacksTriggered:uint = 0;
			
			if (this._waitingCallbacks != null)
			{	
				for (var i:uint = 0; i < this._waitingCallbacks.length; i++)
				{
					var offset:Number = (this._waitingCallbacks.getKeyAt(i) as Number);
					
					// seconds into milliseconds
					offset = (offset * 1000);
					
					// hit any offset that is before our current offset
					if (offset <= this.offset)
					{
						var callbacks:Vector.<Function> = (this._waitingCallbacks.getItemAt(i) as Vector.<Function>);
						
						for (var k:int = (callbacks.length - 1); k >= 0; k--)
						{
							callbacks[k].call();
							
							callbacksTriggered++;
						}
						
						this._waitingCallbacks.removeItem(offset);
					}
				}
			}
			
			if (callbacksTriggered > 0)
			{
				SMILKit.logger.info(callbacksTriggered+" callbacks triggered at "+ this.offset);
			}
		}
		
		protected function onTimerTick(duration:Number, offset:Number):void
		{	
			this.triggerTickNow();
			
			// why send out the tick event here when you can use SharedTime.addEventListener
		}
	}
}