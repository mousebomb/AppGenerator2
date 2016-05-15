package org.mousebomb
{
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.easing.Back;

	import org.mousebomb.interactive.KeyCode;
	import org.mousebomb.interactive.MouseDrager;
	import org.mousebomb.interfaces.IDispose;

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

	/**
	 * @author Mousebomb
	 */
	public class Painting extends Sprite implements IDispose,IFlyIn
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
		public static var lastInstance : Painting = null;
		private var brushSet : BrushSet;
		// 拖拽
		private var _dragger : MouseDrager;
		private var isZooming : Boolean;
		//
		private var minScale : Number = 1.0;
		private var maxScale : Number = 2.0;
		private var backBtn : BackBtn;
		private var soundBtn : SoundBtn;
		private var paintArea : Rectangle ;
		/**
		 * 画画的id
		 */
		private var _id : int;
		/**
		 * 画画的颜色表
		 * key : s+index
		 */
		private var _painted : PaintedModel = PaintedModel.getInstance();

		public function Painting(id : int)
		{
			_id = id;
			var screen : Rectangle = Screen.mainScreen.bounds;

			// brushset
			brushSet = new BrushSet();
			addChild(brushSet);

			//
			backBtn = new BackBtn();
			backBtn.x = 50;
			backBtn.y = GameConf.AD_H + 40;
			addChild(backBtn);
			soundBtn = new SoundBtn();
			soundBtn.x = 50;
			soundBtn.y = GameConf.VISIBLE_SIZE_H - 50;
			addChild(soundBtn);

			paintArea = new Rectangle(0, GameConf.AD_H, GameConf.VISIBLE_SIZE_W - brushSet.width, GameConf.VISIBLE_SIZE_H - GameConf.AD_H);
			var pictureClassName : String = "Pic" + id;
			var clazz : Class = getDefinitionByName(pictureClassName) as Class;
			pic = new clazz();
			// 最小缩放级别
			minScale = 0.5;
			maxScale = 2;
			// var picScaleX : Number = screen.width/pic.width ;
			// var picScaleY : Number =  screen.height/pic.height ;
			// if(minScale<picScaleX) minScale=picScaleX;
			// if(minScale<picScaleY) minScale=picScaleY;
			// if(pic.scaleX<minScale || pic.scaleY<minScale)
			// {pic.scaleX=pic.scaleY=minScale;}

			pic.y = paintArea.y + paintArea.height / 2;
			pic.x = paintArea.width / 2;
			// if(id>4){
			// 从唐老鸭开始才保留原色
			initColor();
			// }
			addChildAt(pic, 0);

			// s是色块，需要保证s可以在屏幕中显示
			var s : Sprite = pic['s'];
			s.addEventListener(MouseEvent.MOUSE_DOWN, onClickStart);
			s.addEventListener(MouseEvent.MOUSE_UP, onClickEnd);
			backBtn.addEventListener(MouseEvent.CLICK, onBackClick);
			soundBtn.addEventListener(MouseEvent.CLICK, onSoundClick);

			//
			addEventListener(Event.ADDED_TO_STAGE, onStage);
			Multitouch.inputMode = MultitouchInputMode.GESTURE;
			
			//
			Sfx.pic.gotoAndStop(10 + _id);

			lastInstance = this;
		}

		private function onSoundClick(event : MouseEvent) : void
		{
			Sfx.pic.gotoAndStop(1);
			Sfx.pic.gotoAndStop(10 + _id);
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
			new GTween(this, 0.5, {y:GameConf.VISIBLE_SIZE_H}, {ease:Back.easeIn, onComplete:onFlyOutComp});
			this.mouseEnabled = this.mouseChildren = false;
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, true);
		}

		private function onFlyOutComp(gtw : GTween) : void
		{
			var scene : MainView;
			if (_painted.modified)
			{	scene = new MainView(_id);
			Sfx.other.gotoAndStop("shine");
			}
			else
				scene = new MainView();
			(parent as TianSe).replaceScene(scene);
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
			this.y = GameConf.VISIBLE_SIZE_H;
			new GTween(this, 0.5, {y:0}, {ease:Back.easeOut});
		}
	}
}
