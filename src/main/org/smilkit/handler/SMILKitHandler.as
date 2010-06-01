package org.smilkit.handler
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import org.smilkit.dom.smil.SMILMediaElement;
	import org.smilkit.dom.smil.SMILRegionElement;
	import org.smilkit.render.RegionContainer;
	import org.smilkit.util.MathHelper;
	import org.smilkit.w3c.dom.IElement;
	import org.smilkit.w3c.dom.smil.ISMILMediaElement;

	public class SMILKitHandler
	{
		protected var _element:IElement;
		
		public function SMILKitHandler(element:IElement)
		{
			this._element = element;
		}
		
		public function get intrinsicDuration():uint
		{
			return 0;
		}
		
		public function get intrinsicWidth():uint
		{
			return 0;
		}
		
		public function get intrinsicHeight():uint
		{
			return 0;
		}
		
		public function get intrinsicSpatial():Boolean
		{
			return false;
		}
		
		public function get intrinsicTemporal():Boolean
		{
			return false;
		}
		
		public function get displayObject():DisplayObject
		{
			return null;
		}
		
		public function get element():ISMILMediaElement
		{
			return (this._element as ISMILMediaElement);
		}
		
		public function load():void
		{
			
		}
		
		public function pause():void
		{
			
		}
		
		public function resume():void
		{
			
		}
		
		public function seek(seekTo:Number):void
		{
			
		}
		
		public function resize():void
		{
			var mediaElement:SMILMediaElement = (this.element as SMILMediaElement);
			var region:SMILRegionElement = (mediaElement.region as SMILRegionElement);
			
			if (region != null)
			{
				var container:RegionContainer = region.regionContainer;
				
				if (container != null)
				{
					var matrix:Rectangle = MathHelper.createMatrixFor(this, container);
					
					if (this.displayObject != null)
					{
						this.displayObject.width = matrix.width;
						this.displayObject.height = matrix.height;
						
						this.displayObject.x = matrix.x;
						this.displayObject.y = matrix.y;
					}
				}
			}
		}
		
		public static function toHandlerMap():HandlerMap
		{
			return null;
			//return new HandlerMap([ "rtmp" ], [ "video/flv" = [ "flv", "f4v" ], "video/mpeg" = [ "mp4", "f4v" ] ]);
		}
	}
}