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
package org.smilkit.time
{	
	public final class SharedTimer
	{
		public static var DELAY:int = 100;
		
		protected static var __instance:SharedTimerInstance = null;
		
		protected static function get instance():SharedTimerInstance
		{
			if (SharedTimer.__instance == null)
			{
				SharedTimer.__instance = new SharedTimerInstance();
			}
			
			return SharedTimer.__instance;
		}
		
		public static function get offset():Number
		{
			return SharedTimer.instance.offset;
		}
		
		public static function subscribe(callback:Function):void
		{
			return SharedTimer.instance.subscribe(callback);
		}
		
		public static function unsubscribe(callback:Function):void
		{
			return SharedTimer.instance.unsubscribe(callback);
		}
		
		public static function every(seconds:Number, callback:Function):void
		{
			return SharedTimer.instance.every(seconds, callback);
		}
		
		public static function removeEvery(seconds:Number, callback:Function):void
		{
			return SharedTimer.instance.removeEvery(seconds, callback);
		}
	}
}

import flash.events.TimerEvent;
import flash.utils.Timer;

import org.smilkit.SMILKit;
import org.smilkit.time.SharedTimer;
import org.utilkit.collection.Hashtable;

class SharedTimerInstance extends Timer
{
	protected var _baseline:Date = null;
	protected var _offset:Number = 0;
	
	protected var _tickers:Vector.<Function> = null;
	protected var _everyCallback:Hashtable = null;
	
	public function SharedTimerInstance()
	{
		super(SharedTimer.DELAY, 0);
		
		this._tickers = new Vector.<Function>();
		
		this.addEventListener(TimerEvent.TIMER, this.onTimer);
		
		// start automatically
		this.start();
	}
	
	public function get offset():Number
	{
		return this._offset;
	}
	
	public override function start():void
	{
		this._baseline = new Date();
		
		super.start();
	}
	
	public override function stop():void
	{
		
	}
	
	public function subscribe(callback:Function):void
	{
		this._tickers.push(callback);
	}
	
	public function unsubscribe(callback:Function):void
	{
		
	}
	
	public function every(seconds:Number, callback:Function):void
	{
		if (this._everyCallback == null)
		{
			this._everyCallback = new Hashtable();
		}
		
		var callbacks:Vector.<Function> = null;
		
		if (!this._everyCallback.hasItem(seconds))
		{
			callbacks = new Vector.<Function>();
			
			this._everyCallback.setItem(seconds, callbacks);
		}
		else
		{
			callbacks = (this._everyCallback.getItem(seconds) as Vector.<Function>);
		}
		
		if (callbacks.indexOf(callback) == -1)
		{
			callbacks.push(callback);
			
			SMILKit.logger.debug("SharedTimer added every callback for every " + seconds + "s");
		}
	}
	
	public function removeEvery(seconds:Number, callback:Function):void
	{
		if (this._everyCallback != null)
		{
			if (this._everyCallback.hasItem(seconds))
			{
				var callbacks:Vector.<Function> = (this._everyCallback.getItem(seconds) as Vector.<Function>);
				
				for (var i:uint = 0; i < callbacks.length; i++)
				{
					if (callbacks[i] == callback)
					{
						callbacks.splice(i, 1);
					}
				}
				
				this._everyCallback.setItem(seconds, callbacks);
			}
		}
	}
	
	protected function onTimer(e:TimerEvent):void
	{
		var delta:Date = new Date();
		var duration:Number = (delta.getTime() - this._baseline.getTime());
		
		this._offset += duration;
		this._baseline = delta;
		
		for (var k:uint = 0; k < this._tickers.length; k++)
		{
			var callback:Function = this._tickers[k];
			
			callback.call(null, duration, this.offset);
		}
		
		if (this._everyCallback != null)
		{
			var triggered:uint = 0;
			
			for (var i:uint = 0; i < this._everyCallback.length; i++)
			{
				var seconds:Number = (this._everyCallback.getKeyAt(i) as Number);
				var milliseconds:uint = (seconds * 1000);
				
				var offset:uint = this.offset;
				var frozen:uint = (Math.floor(this.offset / 1000) * 1000);
				var overlapse:Number = (offset - frozen);
				
				if (overlapse <= duration)
				{
					if (frozen % milliseconds == 0)
					{
						var callbacks:Vector.<Function> = (this._everyCallback.getItemAt(i) as Vector.<Function>);
						
						for (var j:uint = 0; j < callbacks.length; j++)
						{
							callbacks[j].call();
							
							triggered++;
						}
					}
				}
			}
			
			if (triggered > 0)
			{
				//SMILKit.logger.debug("SharedTimer triggered " + triggered + " callbacks with 'every' subscriptions.");
			}
		}
	}
}