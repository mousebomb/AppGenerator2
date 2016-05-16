package org.mousebomb {
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.easing.Back;

import org.mousebomb.GameConf;

import org.mousebomb.GameConf;

import org.mousebomb.GameConf;

import org.mousebomb.interfaces.IDispose;
	import org.mousebomb.ui.Shelf;

	import flash.desktop.NativeApplication;
	import flash.display.DisplayObject;
	import flash.display.Screen;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.utils.getDefinitionByName;

	/**
	 * @author Mousebomb
	 */
	public class MainView extends Sprite implements IDispose,IFlyIn
	{
		private var _shelf : Shelf;
		private var selectedId : int;
		/**
		 * 记录要闪光的图
		 */
		public static var _shinePicId : int;
		/**
		 * 最后翻阅到的页
		 */
		private static var _lastPage : int = 1;
		private var _shelfX : Number;
		private var _prevBtn : SimpleButton;
		private var _nextBtn : SimpleButton;
		private var _replayBtn : SimpleButton;
		private var _moreBtn : SimpleButton;

		public function MainView(shinePicId : int = undefined)
		{
			_shinePicId = shinePicId;
			var scRect : Rectangle = Screen.mainScreen.bounds;
			const LISize : Number = 530.0;
			const LISizeH : Number = 600;
			const cols : int = 1;
			var rows : int = 1;
			const shelfW : Number = GameConf.VISIBLE_SIZE_W * 0.7;
			const shelfH : Number = GameConf.VISIBLE_SIZE_H_MINUS_AD * .82;
			// scRect.width * 0.7;
			// trace('shelfW: ' + (shelfW));
			const MARGINX : Number = (shelfW - (cols * LISize)) / (cols - 1) + LISize;
			const MARGINY : Number = (shelfH - (rows * LISizeH)) / (rows - 1) + LISizeH;
			// trace('MARGINX: ' + (MARGINX));
            //
			_shelf = new Shelf();
			_shelf.y = (GameConf.VISIBLE_SIZE_H_MINUS_AD/2 );
			_shelf.x = _shelfX = (GameConf.VISIBLE_SIZE_W) / 2 ;
			_shelf.config(MARGINX, MARGINY, cols*rows, cols, Localize.LevelItem, addLiCallback);

			_shelf.setList(GameConf.LIST_IDS);
			if (_lastPage != 1)
			{
				_shelf.showPage(_lastPage);
			}
			addChild(_shelf);

            //
            var btnsY:Number = GameConf.VISIBLE_SIZE_H * .92;
			// 翻页按钮
			_prevBtn = new LeftBtn();
			_nextBtn = new RightBtn();
			_prevBtn.name = "prev";
			_nextBtn.name = "next";
			_prevBtn.addEventListener(MouseEvent.CLICK, onPageBtnClick);
			_nextBtn.addEventListener(MouseEvent.CLICK, onPageBtnClick);
			_prevBtn.x = .5*_nextBtn.width;
			_nextBtn.x = GameConf.VISIBLE_SIZE_W - .5 * _prevBtn.width;
			_prevBtn.y = _nextBtn.y = GameConf.VISIBLE_SIZE_H * .5;
			addChild(_prevBtn);
			addChild(_nextBtn);
			validatePageBtns();
			// replay
			_replayBtn = new (Localize.getClass("ReplayBtn"))();
			_replayBtn.x = GameConf.VISIBLE_SIZE_W - _replayBtn.width/2 - 20;
			_replayBtn.y = btnsY;
			_replayBtn.addEventListener(MouseEvent.CLICK, onReplayClick);
			addChild(_replayBtn);
			_moreBtn = new (Localize.getClass("MoreBtn"))();
			_moreBtn.x = _replayBtn.width/2+20;
			_moreBtn.y = btnsY;
			_moreBtn.addEventListener(MouseEvent.CLICK, onMoreClick);
			addChild(_moreBtn);
			_moreBtn.visible = AoaoBridge.isMoreBtnVisible;
			//
			Sfx.init();

			// var wscale : Number = scRect.width / ui.width;
			// var hscale :Number = scRect.height / ui.height;
			// var minScale:Number = wscale> hscale?wscale : hscale;
			// this.scaleX=scaleY = minScale;
			// addEventListener(Event.ADDED_TO_STAGE, onStage);
		}

		private function onMoreClick(event : MouseEvent) : void {
			AoaoBridge.gengDuo(this);
		}

		private function onReplayClick(event : MouseEvent) : void
		{
			new RUSureView(this, confirmReplay);
			Sfx.other.gotoAndStop(1);
			Sfx.other.gotoAndStop("btn");
		}

		private function confirmReplay() : void
		{
			PaintedModel.getInstance().reset();
			_shinePicId = undefined;
			_shelf.showPage(_shelf.curPage);
		}

		// 翻页gtw
		private var pageGtw : GTween;

		private function validatePageBtns() : void
		{
			_prevBtn.mouseEnabled = _shelf.curPage > 1;
			_prevBtn.alpha = _prevBtn.mouseEnabled ? 1.0 : 0.7;
			_nextBtn.mouseEnabled = _shelf.curPage < _shelf.totalPage;
			_nextBtn.alpha = _nextBtn.mouseEnabled ? 1.0 : 0.7;
		}

		private function onPageBtnClick(event : MouseEvent) : void
		{
			if (pageGtw == null)
			{
				pageGtw = new GTween(_shelf, 0.45, null, {ease:Back.easeIn, onComplete:changePagePhrase2});
			}
			else
			{
				pageGtw.onComplete = changePagePhrase2;
				pageGtw.ease = Back.easeIn;
			}
			_changePageArg = (event.currentTarget as SimpleButton).name ;
			switch(_changePageArg)
			{
				case "prev":
					if (_shelf.curPage > 1)
						pageGtw.setValues({x:_shelfX + GameConf.VISIBLE_SIZE_W});
					break;
				case "next":
					if (_shelf.curPage < _shelf.totalPage)
						pageGtw.setValues({x:_shelfX - GameConf.VISIBLE_SIZE_W});
					break;
			}
			Sfx.other.gotoAndStop(1);
			Sfx.other.gotoAndStop("btn");
		}

		// 换页用
		private var _changePageArg : String ;

		private function changePagePhrase2(gtw : GTween) : void
		{
			switch(_changePageArg)
			{
				case "prev":
					_shelf.prevPage();
					_shelf.x = _shelfX - GameConf.VISIBLE_SIZE_W;
					break;
				case "next":
					_shelf.nextPage();
					_shelf.x = _shelfX + GameConf.VISIBLE_SIZE_W;
					break;
			}
			pageGtw.onComplete = null;
			pageGtw.ease = Back.easeOut;
			pageGtw.setValues({x:_shelfX});
			validatePageBtns();
		}

		private function onStage(event : Event) : void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onStage);
			// stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}

		private function onKeyDown(event : KeyboardEvent) : void
		{
			if (event.keyCode == Keyboard.BACK)
			{
				NativeApplication.nativeApplication.exit();
			}
		}

		private function addLiCallback(li : *, vo : int) : void
		{
			li.addEventListener(MouseEvent.CLICK, onLiClick);
			li.addEventListener(MouseEvent.MOUSE_DOWN, onLiDown);
			li.addEventListener(MouseEvent.MOUSE_OUT, onLiUp);
			li.addEventListener(MouseEvent.MOUSE_UP, onLiUp);
			li.id = vo;
			var pictureClassName : String = "Pic" + vo;
			var clazz : Class = getDefinitionByName(pictureClassName) as Class;
			var thumb : Sprite = new clazz();
			var sw : Number = li.m.width / thumb.width ;
			var sh : Number = li.m.height / thumb.height;
			thumb.scaleX = thumb.scaleY = (sw > sh ? sh : sw);
			thumb.x = li.m.x;
			thumb.y = li.m.y;
			// 恢复为玩家填过的颜色
			var _painted : PaintedModel = PaintedModel.getInstance();
			var isPlayed : Boolean = _painted.read(vo);
			// if (isPlayed)
			// {
			var s : Sprite = thumb['s'];
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
			// }
			li.addChild(thumb);
			thumb.mask = li.m;
			li.mouseChildren = false;
			li.titles.gotoAndStop(vo);
			//
			if (_shinePicId == vo)
			{
				li.addChild(new Shine());
			}
		}

		private function onLiUp(event : MouseEvent) : void
		{
			var li : DisplayObject = event.currentTarget as DisplayObject;
			li.scaleX = li.scaleY = 1.0;
		}

		private function onLiDown(event : MouseEvent) : void
		{
			var li : DisplayObject = event.currentTarget as DisplayObject;
			li.scaleX = li.scaleY = 1.1;
		}

		private function onLiClick(event : MouseEvent) : void
		{
			selectedId = event.currentTarget.id;
			_lastPage = _shelf.curPage;
			new GTween(this, 0.5, {y:-GameConf.VISIBLE_SIZE_H}, {ease:Back.easeIn, onComplete:onFlyOutComp});
			this.mouseEnabled = this.mouseChildren = false;
			// stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
            Sfx.other.gotoAndStop(1);
            Sfx.other.gotoAndStop("btn");
		}

		public function flyIn() : void
		{
			this.y = -GameConf.VISIBLE_SIZE_H;
			new GTween(this, 0.5, {y:0}, {ease:Back.easeOut,onComplete:onFlyInComp});
		}

		private function onFlyInComp(gtw : GTween) : void
		{
			AoaoBridge.interstitial(this);
		}
		private function onFlyOutComp(gtw : GTween) : void
		{
			AoaoBridge.banner(this);
			(parent as TianSe).replaceScene(new Painting(selectedId));
		}

		public function dispose() : void
		{
		}
	}
}
