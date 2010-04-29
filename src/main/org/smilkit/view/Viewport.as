package org.smilkit.view
{
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.containers.Canvas;
	
	import org.smilkit.SMILKit;
	import org.smilkit.w3c.dom.smil.ISMILDocument;

	public class Viewport
	{
		protected var _document:ISMILDocument;
		protected var _currentIndex:int = -1;
		protected var _history:Vector.<String>;
		protected var _autoRefresh:Boolean = true;
		
		public function Viewport()
		{
			this._history = new Vector.<String>();
		}
		
		public function get document():ISMILDocument
		{
			return this._document;
		}
		
		public function get timingGraph():Object
		{
			return null;
		}
		
		public function get renderingTree():Object
		{
			return null;
		}
		
		public function get canvas():Canvas
		{
			return null;
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
			//this._timingGraph = new TimingGraph(this._document);
			//this._renderingTree = new RenderingTree(this._timingGraph);
		}
		
		private function onRefreshIOError(e:IOErrorEvent):void
		{
			
		}
		
		private function onRefreshSecurityError(e:SecurityErrorEvent):void
		{
			
		}
	}
}