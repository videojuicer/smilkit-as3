package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.media.Video;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import org.osmf.display.ScaleMode;
	import org.smilkit.SMILKit;
	import org.smilkit.dom.smil.Time;
	import org.smilkit.events.ViewportEvent;
	import org.smilkit.view.Viewport;
	import org.smilkit.util.logger.Logger;
	
	public class SMILKitPlayer extends Sprite
	{
		protected var _viewport:Viewport;
		
		public function SMILKitPlayer()
		{
			// use default asset handlers
			SMILKit.defaults();
			
			var smil:String = this.root.loaderInfo.parameters.hasOwnProperty("smil") ? this.root.loaderInfo.parameters['smil'] : "http://sixty.im/regions.smil?v="+Math.random();
			
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
			
			this._viewport = SMILKit.createEmptyViewport();
			this._viewport.location = smil;
			this._viewport.addEventListener(ViewportEvent.REFRESH_COMPLETE, this.onRefreshComplete);
			this._viewport.drawingBoard.applicationStage = this.stage;
			
			this.graphics.clear();
			
			this.graphics.beginFill(0x000000, 0.1);
			this.graphics.drawRect(0, 0, this.stage.stageWidth, this.stage.stageHeight - 10);
			this.graphics.endFill();
			
			var menu:ContextMenu = new ContextMenu();
			menu.hideBuiltInItems();
			menu.customItems.push(this.createMenuItem("Resume", this.onResumeMenuItem));
			menu.customItems.push(this.createMenuItem("Pause", this.onPauseMenuItem));
			menu.customItems.push(this.createMenuItem("Mute", this.onMuteMenuItem, true));
			menu.customItems.push(this.createMenuItem("Unmute", this.onUnmuteMenuItem));
			menu.customItems.push(this.createMenuItem("Seek 0%", this.onSeek0MenuItem, true));
			menu.customItems.push(this.createMenuItem("Seek 25%", this.onSeek25MenuItem));
			menu.customItems.push(this.createMenuItem("Seek 50%", this.onSeek50MenuItem));
			menu.customItems.push(this.createMenuItem("Seek 75%", this.onSeek75MenuItem));
			menu.customItems.push(this.createMenuItem("Seek 100%", this.onSeek100MenuItem));
			
			this.contextMenu = menu;
			
			this.stage.addEventListener(Event.RESIZE, this.onStageResize);
		}
		
		protected function createMenuItem(text:String, callback:Function, seperatorBefore:Boolean = false):ContextMenuItem
		{
			var item:ContextMenuItem = new ContextMenuItem(text, seperatorBefore);
			item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, callback);
			
			return item;
		}
		
		protected function onResumeMenuItem(e:ContextMenuEvent):void
		{
			this._viewport.resume();
		}
		
		protected function onPauseMenuItem(e:ContextMenuEvent):void
		{
			this._viewport.pause();
		}
		
		protected function onMuteMenuItem(e:ContextMenuEvent):void
		{
			this._viewport.mute();
		}
		
		protected function onUnmuteMenuItem(e:ContextMenuEvent):void
		{
			this._viewport.unmute();
		}
		
		protected function onSeek0MenuItem(e:ContextMenuEvent):void
		{
			this._viewport.seek(0);
			this._viewport.commitSeek();
		}
		
		protected function onSeek25MenuItem(e:ContextMenuEvent):void
		{
			this._viewport.seek(this._viewport.document.dur / 4);
			this._viewport.commitSeek();
		}
		
		protected function onSeek50MenuItem(e:ContextMenuEvent):void
		{
			this._viewport.seek(this._viewport.document.dur / 2);
			this._viewport.commitSeek();
		}
		
		protected function onSeek75MenuItem(e:ContextMenuEvent):void
		{
			this._viewport.seek((this._viewport.document.dur / 4) * 3);
			this._viewport.commitSeek();
		}
		
		protected function onSeek100MenuItem(e:ContextMenuEvent):void
		{
			this._viewport.seek(this._viewport.document.dur);
			this._viewport.commitSeek();
		}
		
		protected function onRefreshComplete(e:ViewportEvent):void
		{
			this.addChild(this._viewport.drawingBoard);
			
			this._viewport.resume();
		}
		
		protected function onStageResize(e:Event):void
		{
			this.graphics.clear();
			
			this.graphics.beginFill(0x000000, 0.1);
			this.graphics.drawRect(0, 0, this.stage.stageWidth, this.stage.stageHeight);
			this.graphics.endFill();
			
			Logger.info("SMILKitPlayer - Application Size: "+this.width+"/"+this.height+" Stage Size: "+this.stage.stageWidth+"/"+this.stage.stageHeight);	
		}
	}
}