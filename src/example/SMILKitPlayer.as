package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.media.Video;
	
	import org.osmf.display.ScaleMode;
	import org.smilkit.SMILKit;
	import org.smilkit.dom.smil.Time;
	import org.smilkit.events.ViewportEvent;
	import org.smilkit.view.Viewport;
	
	public class SMILKitPlayer extends Sprite
	{
		protected var _viewport:Viewport;
		
		public function SMILKitPlayer()
		{
			// use default asset handlers
			SMILKit.defaultHandlers();
			
			var smil:String = this.root.loaderInfo.parameters.hasOwnProperty("smil") ? this.root.loaderInfo.parameters['smil'] : "http://sixty.im/demo.smil?v="+Math.random();
			
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
			
			this._viewport = SMILKit.createEmptyViewport();
			this._viewport.location = smil;
			this._viewport.addEventListener(ViewportEvent.REFRESH_COMPLETE, this.onRefreshComplete);
			this._viewport.drawingBoard.applicationStage = this.stage;
			
			this.graphics.clear();
			
			this.graphics.beginFill(0x000000, 0.1);
			this.graphics.drawRect(0, 0, this.stage.stageWidth, this.stage.stageHeight);
			this.graphics.endFill();
			
			this.stage.addEventListener(Event.RESIZE, this.onStageResize);
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
			
			trace("Application Size: "+this.width+"/"+this.height+" Stage Size: "+this.stage.stageWidth+"/"+this.stage.stageHeight);	
		}
	}
}