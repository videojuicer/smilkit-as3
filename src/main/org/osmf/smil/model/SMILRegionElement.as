package org.osmf.smil.model
{
	public class SMILRegionElement extends SMILElement
	{
		public function SMILRegionElement()
		{
			super(SMILElementType.REGION);
		}
		
		public function get id():String
		{
			return _id;
		}
		
		public function set id(value:String):void
		{
			_id = value;
		}
		
		public function get width():String
		{
			return _width;
		}
		
		public function set width(value:String):void
		{
			_width = value;
		}
		
		public function get height():String
		{
			return _height;
		}
		
		public function set height(value:String):void
		{
			_height = value;
		}
		
		public function get left():String
		{
			return _left;
		}
		
		public function set left(value:String):void
		{
			_left = value;
		}
		
		public function get right():String
		{
			return _right;
		}
		
		public function set right(value:String):void
		{
			_right = value;
		}
		
		public function get top():String
		{
			return _top;
		}
		
		public function set top(value:String):void
		{
			_top = value;
		}
		
		public function get bottom():String
		{
			return _bottom;
		}
		
		public function set bottom(value:String):void
		{
			_bottom = value;
		}
		
		public function get index():String
		{
			return _index;
		}
		
		public function set index(value:String):void
		{
			_index = value;
		}
		
		public function get backgroundColor():String
		{
			return _backgroundColor;
		}
		
		public function set backgroundColor(value:String):void
		{
			_backgroundColor = value;
		}
		
		private var _id:String;
		private var _width:String;
		private var _height:String;
		private var _left:String;
		private var _right:String;
		private var _top:String;
		private var _bottom:String;
		private var _index:String;
		private var _backgroundColor:String;
	}
}