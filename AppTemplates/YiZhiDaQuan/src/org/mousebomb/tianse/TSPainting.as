package org.mousebomb.tianse
{

	import ex.BackBtn;

	import flash.display.DisplayObject;
	import flash.display.Screen;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.GesturePhase;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TransformGestureEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.getDefinitionByName;


	import org.mousebomb.*;
	import org.mousebomb.interactive.MouseDrager;
	import org.mousebomb.interfaces.IDispose;

	import yizhidaquan.YiZhiDaQuan;

	/**
	 * @author Mousebomb
	 */
	public class TSPainting extends Sprite implements IDispose,IFlyIn
	{
		/**
		 * 外部提供的着色图
		 */
		private var pic : Sprite ;
		/**
		 * 笔刷颜色
		 */
		public var brushColor : uint = 0xffffff;
		/**
		 * 半单例
		 */
		public static var lastInstance : TSPainting = null;
		private var brushSet : TSBrushSet;
		// 拖拽
		private var _dragger : MouseDrager;
		private var isZooming : Boolean;
		//
		private var minScale : Number = 1.0;
		private var maxScale : Number = 2.0;
		private var paintArea : Rectangle ;
		/**
		 * 画画的id
		 */
		private var _id : int;
		/**
		 * 画画的颜色表
		 * key : s+index
		 */
		private var _painted : TSPaintedModel = TSPaintedModel.getInstance();

		private var ui :UITSGame;
		public function TSPainting(id : int)
		{
			_id = id;
			ui = new UITSGame();
			addChild(ui);
			var screen : Rectangle = Screen.mainScreen.bounds;

			// brushset
			brushSet = new TSBrushSet();
			ui.addChild(brushSet);

			//
			paintArea = new Rectangle(0, ui.backBtn.height, GameConf.DESIGN_SIZE_W, GameConf.VISIBLE_SIZE_H_MINUS_AD- brushSet.height - ui.backBtn.height);
			var pictureClassName : String = "Pic" + id;
			var clazz : Class = getDefinitionByName(pictureClassName) as Class;
			pic = new clazz();
            // 从pic适应计算比例 suitScale最适合的
			var picScaleX : Number = paintArea.width/pic.width ;
			var picScaleY : Number =  paintArea.height/pic.height ;
            var suitScale :Number = (picScaleX < picScaleY)? picScaleX: picScaleY;
			pic.scaleX=pic.scaleY=suitScale;
			// 最小缩放级别
			minScale = 0.5 * suitScale;
			maxScale = 2 * suitScale;

			pic.y = paintArea.y + paintArea.height / 2;
			pic.x = paintArea.width / 2;
			// if(id>4){
			// 从唐老鸭开始才保留原色
			initColor();
			// }
			ui.addChildAt(pic, ui.getChildIndex(ui.backBtn));


			// s是色块，需要保证s可以在屏幕中显示
			var s : Sprite = pic['s'];
			s.addEventListener(MouseEvent.MOUSE_DOWN, onClickStart);
			s.addEventListener(MouseEvent.MOUSE_UP, onClickEnd);
			ui.backBtn.addEventListener(MouseEvent.CLICK, onBackClick);
			ui.soundBtn.addEventListener(MouseEvent.CLICK, onSoundClick);

			//
			addEventListener(Event.ADDED_TO_STAGE, onStage);
			Multitouch.inputMode = MultitouchInputMode.GESTURE;
			
			//
			SoundMan.playPic(_id);

			lastInstance = this;
		}

		private function onSoundClick(event : MouseEvent) : void
		{
			SoundMan.playPic(_id);
		}

		public function dispose() : void
		{
			_dragger.stopDrag();
			pic['s'].removeEventListener(MouseEvent.MOUSE_DOWN, onClickStart);
			pic['s'].removeEventListener(MouseEvent.MOUSE_UP, onClickEnd);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp, true);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, true);
		}

		private function onBackClick(event : MouseEvent) : void
		{
			backToMain();
		}

		private function backToMain() : void
		{
			if (_painted.modified)
				_painted.save(_id);
//			TweenLite.to(this , .5 , {y:GameConf.VISIBLE_SIZE_H , ease:Back.easeIn, onComplete:onFlyOutComp});
			this.mouseEnabled = this.mouseChildren = false;
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, true);
			SoundMan.playSfx(SoundMan.BTN);
			onFlyOutComp();
		}

		private function onFlyOutComp() : void
		{
			var scene : TSLevel;
			if (_painted.modified)
			{	scene = new TSLevel(_id);
				SoundMan.playSfx(SoundMan.SHINE);
			}
			else
				scene = new TSLevel();
			YiZhiDaQuan.instance.replaceScene(scene);
		}

		private function onStage(event : Event) : void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onStage);
			stage.addEventListener(TransformGestureEvent.GESTURE_ZOOM, onGestureZoom, true);

			_dragger = new MouseDrager(pic);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, true);
			// 优先级高覆盖
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, true);
		}

		private function onKeyDown(event : KeyboardEvent) : void
		{
			if (event.keyCode == Keyboard.BACK)
			{
				// android back
				backToMain();
				event.preventDefault();
				event.stopImmediatePropagation();
			}
		}

		private function onMouseUp(event : MouseEvent) : void
		{
			if (_dragger.isDragging)
			{
				event.stopPropagation();
			}
			_dragger.stopDrag();
		}

		private function onMouseDown(event : MouseEvent) : void
		{
			// var picRect : Rectangle = new Rectangle(paintArea.width - pic.width / 2, pic.height / 2 + paintArea.height - pic.height, pic.width - paintArea.width, pic.height - paintArea.height);
			_dragger.startDrag(paintArea);
			// _dragger.startDrag();
		}

		private var _gestZoom : Number;

		private function onGestureZoom(event : TransformGestureEvent) : void
		{
			if (event.phase == GesturePhase.BEGIN)
			{
				if (_dragger.isAlreadyStart) _dragger.stopDrag();
				isZooming = true;
				_isClick = false;
				// 缩放
				// _gestZoom = event.scaleX * pic.scaleX;
				// pic.scaleX = pic.scaleY = _gestZoom;
			}
			if (event.phase == GesturePhase.UPDATE )
			{
				// 缩放
				_gestZoom = event.scaleX * pic.scaleX;
				if (_gestZoom < minScale) _gestZoom = minScale;
				if (_gestZoom > maxScale) _gestZoom = maxScale;
				pic.scaleX = pic.scaleY = _gestZoom;
				//
			}
			if (event.phase == GesturePhase.END)
			{
				isZooming = false;
				event.stopPropagation();
			}
		}

		private function initColor() : void
		{
			var s : Sprite = pic['s'];

			// 保存的
			_painted.read(_id);

			for (var i : int = s.numChildren - 1; i >= 0; i--)
			{
				var shape : DisplayObject = s.getChildAt(i) as DisplayObject;
				if (shape)
				{
					var ct : ColorTransform = new ColorTransform();
					ct.color = _painted.getColor(i);
					shape.transform.colorTransform = ct;
				}
			}
		}

		private var _isClick : Boolean = false;

		private function onClickStart(event : MouseEvent) : void
		{
			_isClick = true;
		}

		private function onClickEnd(event : MouseEvent) : void
		{
			if ( false == _isClick) return;
			var pLocal : Point = new Point(event.stageX, event.stageY);
			var s : Sprite = pic['s'];
			var objects : Array = stage.getObjectsUnderPoint(pLocal);
			objects = objects.filter(function(obj : DisplayObject, index : int, arr : Array) : Boolean
			{
				return (obj.parent == s);
			});

			var shape : DisplayObject = objects[objects.length - 1] as DisplayObject;
			if (shape)
			{
				var ct : ColorTransform = new ColorTransform();
				ct.color = brushColor;
				_painted.putColor(brushColor, s.getChildIndex(shape));
				shape.transform.colorTransform = ct;
			}
		}

		public function flyIn() : void
		{
//			this.y = GameConf.VISIBLE_SIZE_H;
//			TweenLite.to(this ,.5 , {y:0 , ease:Back.easeOut});
		}
	}
}
