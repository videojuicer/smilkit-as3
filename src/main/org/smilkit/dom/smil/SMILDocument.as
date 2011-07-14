package org.smilkit.dom.smil
{
	import org.smilkit.SMILKit;
	import org.smilkit.dom.smil.display.SMILDocumentDisplayStack;
	import org.smilkit.dom.smil.SMILDocumentLoadables;
	import org.smilkit.dom.smil.events.SMILEventStack;
	import org.smilkit.dom.smil.expressions.SMILDocumentVariables;
	import org.smilkit.dom.smil.time.SMILTimeGraph;
	import org.smilkit.dom.smil.time.SMILTimeInstance;
	import org.smilkit.dom.smil.time.SMILTimeScheduler;
	import org.smilkit.load.LoadScheduler;
	import org.smilkit.events.HeartbeatEvent;
	import org.smilkit.view.ViewportObjectPool;
	import org.smilkit.w3c.dom.IDocumentType;
	import org.utilkit.util.Environment;
	import org.utilkit.util.Platform;
	
	public class SMILDocument extends SMILCoreDocument
	{
		protected var _scheduler:SMILTimeScheduler;
		protected var _timeGraph:SMILTimeGraph;
		protected var _loadables:SMILDocumentLoadables;
		protected var _loadScheduler:LoadScheduler;
		
		protected var _displayStack:SMILDocumentDisplayStack;
		
		protected var _variables:SMILDocumentVariables;
		protected var _eventStack:SMILEventStack;
		
		protected var _activeContainers:Vector.<SMILTimeInstance>;
		
		public function SMILDocument(documentType:IDocumentType)
		{
			super(documentType);
			
			// keeps track of time
			this._scheduler = new SMILTimeScheduler(this);

			// handles active elements, rebuilds itself
			this._timeGraph = new SMILTimeGraph(this);
			
			// handles painting
			this._displayStack = new SMILDocumentDisplayStack();
			
			// magic variables for smil
			this._variables = new SMILDocumentVariables(this);
			
			// catches loadable property changes from ElementLoadableContainers
			this._loadables = new SMILDocumentLoadables(this);
			
			// create the load scheduler instance for this document
			this._loadScheduler = new LoadScheduler(this);
			
			// default variables
			this.setupDocumentVariables();
		}
		
		public function get loadScheduler():LoadScheduler
		{
			return this._loadScheduler;
		}
		
		public function get scheduler():SMILTimeScheduler
		{
			return this._scheduler;
		}
		
		public function get timeGraph():SMILTimeGraph
		{
			return this._timeGraph;
		}
		
		public function get displayStack():SMILDocumentDisplayStack
		{
			return this._displayStack;
		}
		
		public function get loadables():SMILDocumentLoadables
		{
			return this._loadables;
		}
		
		public function get eventStack():SMILEventStack
		{
			return this._eventStack;
		}
		
		public function get variables():SMILDocumentVariables
		{
			return this._variables;
		}
		
		public override function set viewportObjectPool(viewportObjectPool:ViewportObjectPool):void
		{
			super.viewportObjectPool = viewportObjectPool;
			
			// setup listeners
			//this.viewportObjectPool.viewport.heartbeat.addEventListener(HeartbeatEvent.RUNNING_OFFSET_CHANGED, this.onHeartbeatOffsetChanged);
		}
		
		protected function onHeartbeatOffsetChanged(e:HeartbeatEvent):void
		{
			//this.triggerEventsAt(e.runningOffset);
		}
		
		protected var _safeOffsetMin:Number = 0;
		protected var _safeOffsetMax:Number = 0;
		
		/*
		protected function triggerEventsAt(offset:Number):void
		{
			// whats starting to play
			// whats ending
			if (this._safeOffsetMin <= offset >= this._safeOffsetMax)
			{
				var nextContainers:Vector.<SMILTimeInstance> = new Vector.<SMILTimeInstance>();
				
				for (var i:uint = 0; i < this.viewportObjectPool.timingGraph.elements.length; i++)
				{
					var node:SMILTimeInstance = this.viewportObjectPool.timingGraph.elements[i];
					var active:Boolean = node.activeAt(offset);
					
					//if (node.begin != Time.UNRESOLVED && node.begin > offset && (node.begin < this._safeOffsetMin || this._safeOffsetMin == 0) && node.begin < this._safeOffsetMax)
					//{
					//	this._safeOffsetMax = node.begin;
					//}
						
					if (active)
					{
						if (this._activeContainers.indexOf(node) == -1)
						{
							// node->beginEvent
						}
						else
						{
							// already active, so keep on new list but no neeed to send an event
							this._safeOffsetMin = offset;
						}
						
						nextContainers.push(node);
					}
					else
					{
						if (this._activeContainers.indexOf(node) != -1)
						{
							// node->endEvent
						}
						else
						{
							// not in the active containers and not active now
						}
					}
				}
				
				this._activeContainers = nextContainers;
			}
		}
		*/
		
		/**
		 * Current running offset, collected from the Viewport and calculated outside
		 * of the DOM. Returns 0 if the Viewport link does not exist.
		 */
		public function get offset():Number
		{
			return (this.scheduler.offset / 1000);
		}
		
		public function setupDocumentVariables():void
		{
			//var mutation:Boolean = this._mutationEvents;
			
			//this._mutationEvents = false;
			this.applyMutation(this, function():void {
				// SMIL 3.0 default system variables
				this.variables.set(SMILDocumentVariables.SYSTEM_AUDIO_DESC, "off");
				this.variables.set(SMILDocumentVariables.SYSTEM_BASE_PROFILE, "");
				this.variables.set(SMILDocumentVariables.SYSTEM_BITRATE, 0);
				this.variables.set(SMILDocumentVariables.SYSTEM_CAPTIONS, "off");
				this.variables.set(SMILDocumentVariables.SYSTEM_COMPONENT, "");
				this.variables.set(SMILDocumentVariables.SYSTEM_CONTENT_LOCATION, "");
				this.variables.set(SMILDocumentVariables.SYSTEM_CPU, Platform.cpuArchitecture);
				this.variables.set(SMILDocumentVariables.SYSTEM_LANGUAGE, Environment.language);
				this.variables.set(SMILDocumentVariables.SYSTEM_OPERATING_SYSTEM, Platform.operatingSystem);
				this.variables.set(SMILDocumentVariables.SYSTEM_OVERDUB_OR_CAPTION, "overdub");
				this.variables.set(SMILDocumentVariables.SYSTEM_OVERDUB_OR_SUBTITLE, "overdub");
				this.variables.set(SMILDocumentVariables.SYSTEM_REQUIRED, "");
				this.variables.set(SMILDocumentVariables.SYSTEM_SCREEN_DEPTH, 0);
				this.variables.set(SMILDocumentVariables.SYSTEM_SCREEN_SIZE, Environment.screenSize);
				this.variables.set(SMILDocumentVariables.SYSTEM_VERSION, 3.0);
				
				
				// magic SMILKit variables
				this.variables.set("smilkitVersion", SMILKit.version);
			});
			
			//this._mutationEvents = mutation;
		}
		
		
	}
}