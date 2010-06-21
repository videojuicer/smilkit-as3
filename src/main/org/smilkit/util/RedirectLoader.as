package org.smilkit.util
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	public class RedirectLoader extends EventDispatcher
	{
		protected var _loaders:Vector.<Loader>;
		protected var _context:LoaderContext;
		
		protected var _lastRequest:URLRequest;
		
		public function RedirectLoader()
		{
			this._loaders = new Vector.<Loader>();
		}
		
		public function get currentLoader():Loader
		{
			if (this._loaders.length == 0)
			{
				return null;
			}
			
			return this._loaders[(this._loaders.length - 1)];
		}
		
		public function load(request:URLRequest, context:LoaderContext):void
		{
			this._context = context;
			
			this.loadThroughRedirect(request);
		}
		
		public function close():void
		{
			for (var i:int = 0; i < this._loaders.length; i++)
			{
				this._loaders[i].close();
			}
			
			var object:Object = { loaders: this._loaders };
			this._loaders = null;
			
			delete object.loaders;
		}
		
		protected function loadThroughRedirect(request:URLRequest):void
		{
			var loader:Loader = new Loader();
			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.onLoaderComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.onLoaderError);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, this.onLoaderProgress);
			
			this._loaders.push(loader);
			this._lastRequest = request;
			
			loader.load(request, this._context);
		}
		
		protected function onLoaderComplete(e:Event):void
		{
			var current_url:String = (e.target as LoaderInfo).url;
			
			if (current_url == this._lastRequest.url)
			{
				// finished going through all the redirects
				this.dispatchEvent(e.clone());
			}
			else
			{
				this.loadThroughRedirect(new URLRequest(current_url));
			}
		}
		
		protected function onLoaderError(e:IOErrorEvent):void
		{
			this.dispatchEvent(e.clone());
		}
		
		protected function onLoaderProgress(e:ProgressEvent):void
		{
			this.dispatchEvent(e.clone());
		}
	}
}