package pintie {
	import flash.display.Bitmap;
	import com.greensock.TweenLite;
	import com.greensock.easing.Back;

	import org.mousebomb.interactive.DragHandler;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	/**
	 * 坑位
	 * @author rhett
	 */
	public class HoleLi extends Sprite {
		private var child : PartShape;
		private var _type : String;
		private var dragHandler : DragHandler;
		// 作为选择 (type == SOURCE)的时候的index 0~2
		public var choiceIndex : int;
		// 校验这个对不对
		private var _rect : Rectangle;

		public function HoleLi() {
			mouseChildren = false;
		}

		private function onUp(event : MouseEvent) : void {
			scaleX = suitW;
			scaleY = suitH;
		}

		private function onDown(event : MouseEvent) : void {
			TweenLite.to(this, 0.3, {scaleX:suitW * bitmapOriginW / HOLE_W_SMALL, scaleY:suitH * bitmapOriginH / HOLE_H_SMALL, ease:Back.easeInOut});
		}

		/**  */
		public static const DRAG_SOURCE : String = "DRAG_SOURCE";
		/**  */
		public static const DRAG_TARGET : String = "DRAG_TARGET";
		private var suitW : Number;
		private var suitH : Number;
		// public static const HOLE_W : Number = 160;
		// public static const HOLE_H : Number = 160;
		// 位图原图中碎片随机出的大小
		public var bitmapOriginW : Number;
		public var bitmapOriginH : Number;
		public static const HOLE_W_SMALL : Number = 140;
		public static const HOLE_H_SMALL : Number = 140;

		//
		/**
		 * 对应的坑位的index | 
		 */
		public function setContent(_curLevelBitmap : Bitmap, rect : Rectangle,shapeId:uint, type : String) : void {
			_rect = rect;
			
			
			
			child = new PartShape(_curLevelBitmap, _rect, shapeId);
			var holeW : Number = _rect.width;
			var holeH : Number = _rect.height;
			if (type == HoleLi.DRAG_SOURCE)
			{
				holeW = HoleLi.HOLE_W_SMALL;
				holeH = HoleLi.HOLE_H_SMALL;
			}
			var sx : Number = holeW / child.width ;
			var sy : Number = holeH / child.height ;
			var scale : Number = sx < sy ? sx : sy;
			scaleX = scaleY = scale;
//			child.x = holeW / 2;
//			child.y = holeH / 2;
			
			
			
			
			suitW = scaleX;
			suitH = scaleY;
			_type = type;

			if (type == HoleLi.DRAG_SOURCE) {
				// this.graphics.lineStyle(2,0xff0000);
				// this.graphics.beginFill(0xff0000,0);
				// this.graphics.drawRect(0, 0, HOLE_W, HOLE_H);
				// this.graphics.endFill();
				child.show();
				dragHandler = new DragHandler();
				dragHandler.init(this, this);
				this.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
				this.addEventListener(MouseEvent.MOUSE_UP, onUp);
				bitmapOriginW = _rect.width;
				bitmapOriginH = _rect.height;
			} else {
				child.black();
				//
			}
			addChild(child);
//			addChild(new TestFlag());
		}

		public function playCorrect() : void {
			if (type == DRAG_SOURCE) {
				TweenLite.to(this, 0.2, {alpha:0, onComplete:onSourceTweenComplete});
				this.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
				this.removeEventListener(MouseEvent.MOUSE_UP, onUp);
			} else if (type == HoleLi.DRAG_TARGET) {
				child.show();
				scaleX = suitW * 1.3;
				scaleY = suitH * 1.3;
				TweenLite.to(this, 0.3, {scaleX:suitW, scaleY:suitH, ease:Back.easeInOut, onComplete:onSourceTweenComplete});
			}
		}

		private function onSourceTweenComplete() : void {
			if (parent) parent.removeChild(this);
		}

		public function get type() : String {
			return _type;
		}

		public function get rect() : Rectangle {
			return _rect;
		}
	}
}

import flash.display.Shape;


class TestFlag extends Shape {
	public function TestFlag( c :uint = 0xff0000) {
		graphics.beginFill(c);
		graphics.drawCircle(0, 0, 10);
		graphics.endFill();
	}
}