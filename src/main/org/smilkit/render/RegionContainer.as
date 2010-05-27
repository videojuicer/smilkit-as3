package org.smilkit.render
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import org.smilkit.dom.smil.SMILRegionElement;
	import org.smilkit.util.MathHelper;

	public class RegionContainer extends Sprite
	{
		protected var _region:SMILRegionElement;
		protected var _matrix:Rectangle;
		
		public function RegionContainer(region:SMILRegionElement)
		{
			super();
			
			this._region = region;
			
			this.addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
		}
		
		public function get region():SMILRegionElement
		{
			return this._region;
		}
		
		public override function get width():Number
		{
			if (this._matrix == null || this._matrix.width == 0)
			{
				return super.width;
			}
			
			return this._matrix.width;
		}
		
		public override function get height():Number
		{
			if (this._matrix == null || this._matrix.height == 0)
			{
				return super.height;
			}
			
			return this._matrix.height;
		}

		public function invalidateSizeAndLayout():void
		{
			if (this.parent != null)
			{
				this._matrix = new Rectangle();
				
				var width:String = this.region.getAttribute("width");
				var height:String = this.region.getAttribute("height");
				
				var parentWidth:int = this.parent.width;
				var parentHeight:int = this.parent.height;
				
				if (MathHelper.isPercentage(width))
				{
					var percentWidth:int = MathHelper.percentageToInteger(width);
					
					this._matrix.width = (percentWidth / 100) * parentWidth;
				}
				else
				{
					this._matrix.width = (width as uint);
				}
				
				if (MathHelper.isPercentage(height))
				{
					var percentHeight:int = MathHelper.percentageToInteger(height);
					
					this._matrix.height = (percentHeight / 100) * parentHeight;
				}
				else
				{
					this._matrix.height = (height as uint);
				}
				
				var top:int = (this.region.top as uint);
				var bottom:int = (this.region.bottom as uint);
				var left:int = (this.region.left as uint);
				var right:int = (this.region.right as uint);
				
				/*
				if (top != NaN)
				{
				this._matrix.x = top;
				}
				
				if (bottom != NaN)
				{
				this._matrix.x = (parentHeight - bottom);
				}
				
				if (left != NaN)
				{
				this._matrix.y = left;
				}
				
				if (right != NaN)
				{
				this._matrix.y = (parentWidth - right);
				}
				*/
				
				this.graphics.clear();
				this.graphics.beginFill(0x000000, 0);
				this.graphics.lineStyle(0, 0xff0000, 0.5);
				this.graphics.drawRect(0, 0, this._matrix.width, this._matrix.height);
				this.graphics.endFill();
				
				// actually position using the matrix as a guide
				this.width = this._matrix.width;
				this.height = this._matrix.height;
				
				this.x = this._matrix.x;
				this.y = this._matrix.y;
			}
		}
		
		protected function onAddedToStage(e:Event):void
		{
			this.invalidateSizeAndLayout();
		}
	}
}