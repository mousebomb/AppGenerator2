package tiezhi
{
	import com.greensock.easing.Back;
	import org.mousebomb.utils.FrameScript;

	import com.greensock.TweenLite;

	import flash.events.MouseEvent;

	import org.mousebomb.interactive.DragHandler;

	import flash.display.MovieClip;
	import flash.display.Sprite;

	/**
	 * 坑位
	 * @author rhett
	 */
	public class HoleLi extends Sprite
	{
		private var child : MovieClip;
		private var _index : int;
		private var _type : String;
		private var dragHandler : DragHandler;
		// 作为选择 (type == SOURCE)的时候的index 0~2
		public var choiceIndex : int;

		public function HoleLi()
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
		
		//
		private var roundPic :PicRound;
		
		/**
		 * 对应的坑位的index | 
		 */
		public function setContent(child : MovieClip, index : int, type : String) : void
		{
			suitW = child.width;
			suitH = child.height;
			_type = type;
			_index = index;
			this.child = child;
			if (type == HoleLi.DRAG_SOURCE)
			{
//				this.graphics.lineStyle(2,0xff0000);
				this.graphics.beginFill(0,0);
				this.graphics.drawRect(0, 0, HOLE_W, HOLE_H);
				child.gotoAndStop("show");
				dragHandler = new DragHandler();
				dragHandler.init(this, this);
				this.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
				this.addEventListener(MouseEvent.MOUSE_UP, onUp);
			}
			else
			{
				child.gotoAndStop("black");
				child.addFrameScript(child.totalFrames - 1, child.stop);
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
				TweenLite.to(this, 0.2, {alpha:0, onComplete:onSourceTweenComplete});
			}
			else if (type == HoleLi.DRAG_TARGET)
			{
				child.width = suitW * 1.3;
				child.height = suitH * 1.3;
				TweenLite.to(child, 0.3, {width:suitW , height:suitH , ease: Back.easeInOut });
				child.gotoAndPlay("show");
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
