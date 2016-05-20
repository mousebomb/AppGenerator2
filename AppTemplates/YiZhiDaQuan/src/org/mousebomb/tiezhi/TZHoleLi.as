package org.mousebomb.tiezhi
{

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Point;

	import gs.TweenLite;
	import gs.easing.Back;

	import org.mousebomb.SoundMan;
	import org.mousebomb.interactive.DragHandler;

	/**
	 * 坑位
	 * @author rhett
	 */
	public class TZHoleLi extends Sprite
	{
		private var child : Sprite;
		private var _index : int;
		private var _type : String;
		private var dragHandler : DragHandler;
		// 作为选择 (type == SOURCE)的时候的index 0~2
		public var choiceIndex : int;

		public function TZHoleLi()
		{
			mouseChildren = false;
		}

		private function onUp(event : MouseEvent) : void
		{
			child.width = suitW;
			child.height = suitH;
		}

		private function onDown(event : MouseEvent) : void
		{
			SoundMan.playSfx(SoundMan.BTN);
			TweenLite.to(child, 0.3, {width:suitW * HOLE_W/HOLE_W_SMALL , height:suitH * HOLE_H/HOLE_H_SMALL  , ease:Back.easeInOut});
		}

		/**  */
		public static const DRAG_SOURCE : String = "DRAG_SOURCE";
		/**  */
		public static const DRAG_TARGET : String = "DRAG_TARGET";
		private var suitW : Number;
		private var suitH : Number;

		public static const HOLE_W : Number = 160;
		public static const HOLE_H : Number = 160;
		public static const HOLE_W_SMALL : Number = 140;
		public static const HOLE_H_SMALL : Number = 140;
		

        public function get centerPos ():Point{ return   this.localToGlobal(new Point(child.x,child.y));  }
		//
		private var roundPic :PicRound;
		
		/**
		 * 对应的坑位的index | 
		 */
		public function setContent(child : Sprite, index : int, type : String) : void
		{
			suitW = child.width;
			suitH = child.height;
			_type = type;
			_index = index;
			this.child = child;
			if (type == TZHoleLi.DRAG_SOURCE)
			{
//				this.graphics.lineStyle(2,0xff0000);
				this.graphics.beginFill(0,0);
				this.graphics.drawRect(0, 0, HOLE_W, HOLE_H);
				show();
				dragHandler = new DragHandler();
				dragHandler.init(this, this);
				this.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
				this.addEventListener(MouseEvent.MOUSE_UP, onUp);
			}
			else
			{
				black();
				//
				roundPic = new PicRound();
				roundPic.width = 1.8*HOLE_W;
				roundPic.height =1.8* HOLE_H;
				roundPic.x = HOLE_W /2;
				roundPic.y = HOLE_H /2;
				addChild(roundPic);
			}
			addChild(child);
		}

		private function black():void
		{
var ct :ColorTransform = new ColorTransform(0,0,0,1);
			child.transform.colorTransform = ct;
		}

		private function show():void
		{
			var ct :ColorTransform = new ColorTransform();
			child.transform.colorTransform = ct;
		}

		public function get index() : int
		{
			return _index;
		}

		public function set index(index : int) : void
		{
			this._index = index;
		}

		public function playCorrect() : void
		{
			if (type == DRAG_SOURCE)
			{
				this.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
				this.removeEventListener(MouseEvent.MOUSE_UP, onUp);
				this.mouseEnabled=false;
				this.mouseChildren=false;
				TweenLite.to(this, 0.2, {alpha:0, onComplete:onSourceTweenComplete});
			}
			else if (type == TZHoleLi.DRAG_TARGET)
			{
				child.width = suitW * 1.3;
				child.height = suitH * 1.3;
				TweenLite.to(child, 0.3, {width:suitW , height:suitH , ease: Back.easeInOut });
				show();
			}
		}

		private function onSourceTweenComplete() : void
		{
			parent.removeChild(this);
		}

		public function get type() : String
		{
			return _type;
		}
	}
}
