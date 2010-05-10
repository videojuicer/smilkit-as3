package org.smilkit.view
{
	import flash.display.Sprite;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.containers.Canvas;
	
	import org.smilkit.SMILKit;
	import org.smilkit.events.ViewportEvent;
	import org.smilkit.render.RenderTree;
	import org.smilkit.time.Heartbeat;
	import org.smilkit.time.TimingGraph;
	import org.smilkit.w3c.dom.smil.ISMILDocument;

	public class Viewport extends EventDispatcher
	{
		protected var _document:ISMILDocument;
		protected var _timingGraph:TimingGraph;
		protected var _renderTree:RenderTree;
		protected var _heartbeat:Heartbeat;
		
		protected var _currentIndex:int = -1;
		protected var _history:Vector.<String>;
		protected var _autoRefresh:Boolean = true;
		
		public function Viewport()
		{
			this._history = new Vector.<String>();
			this._heartbeat = new Heartbeat(Heartbeat.BPS_5);
		}
		
		public function get offset():Number
		{
			return 0;
		}
		
		public function get document():ISMILDocument
		{
			return this._document;
		}
		
		public function get timingGraph():TimingGraph
		{
			return this._timingGraph;
		}
		
		public function get renderingTree():Object
		{
			return null;
		}
		
		public function get heartbeat():Heartbeat
		{
			return this._heartbeat;
		}
		
		public function get canvas():Sprite
		{
			return this._renderTree.canvas;
		}
		
		public function get history():Vector.<String>
		{
			return this._history;
		}
		
		public function get location():String
		{
			if (this._currentIndex == -1)
			{
				return null;
			}
			
			return this._history[this._currentIndex];
		}
		
		public function set location(location:String):void
		{
			if (location == this.location)
			{
				throw new IllegalOperationError("Attempting to navigate to the same location.");
			}
			
			this._history[this._history.length] = location;
			this._currentIndex = this._history.length-1;
			
			if (this.autoRefresh)
			{
				this.refresh();
			}
		}
		
		public function get autoRefresh():Boolean
		{
			return this._autoRefresh;
		}
		
		public function set autoRefresh(autoRefresh:Boolean):void
		{
			this._autoRefresh = autoRefresh;
		}
		
		public function refresh():void
		{
			if (this.location == null || this.location == "")
			{
				throw new IllegalOperationError("Unable to navigate to null location.");
			}
			
			var request:URLRequest = new URLRequest(this.location);
			var loader:URLLoader = new URLLoader();
			
			loader.addEventListener(IOErrorEvent.IO_ERROR, this.onRefreshIOError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onRefreshSecurityError);
			loader.addEventListener(Event.COMPLETE, this.onRefreshComplete);
			
			loader.load(request);
		}
		
		public function back():Boolean
		{
			if (this._currentIndex > 0)
			{
				this._currentIndex--;
				
				if (this.autoRefresh)
				{
					this.refresh();
				}
			}
			
			return false;
		}
		
		public function forward():Boolean
		{
			if (this._currentIndex < (this._history.length - 1))
			{
				this._currentIndex++;
				
				if (this.autoRefresh)
				{
					this.refresh();
				}
			}
			
			return false;
		}
		
		private function onRefreshComplete(e:Event):void
		{
			// parse dom
			this._document = (SMILKit.loadSMILDocument(e.target.data) as ISMILDocument);
			this._timingGraph = new TimingGraph(this._document);
			this._renderTree = new RenderTree(this, this._timingGraph);
			
			this.dispatchEvent(new ViewportEvent(ViewportEvent.REFRESH_COMPLETE));
		}
		
		private function onRefreshIOError(e:IOErrorEvent):void
		{
			
		}
		
		private function onRefreshSecurityError(e:SecurityErrorEvent):void
		{
			
		}
	}
}