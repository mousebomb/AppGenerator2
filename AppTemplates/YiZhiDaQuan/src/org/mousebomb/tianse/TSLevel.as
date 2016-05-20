package org.mousebomb.tianse {

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

	import gs.TweenLite;

	import gs.easing.Back;

	import org.mousebomb.*;
	import org.mousebomb.interfaces.IDispose;
	import org.mousebomb.ui.Shelf;

	import yizhidaquan.YZSelectGame;
	import yizhidaquan.YiZhiDaQuan;

	/**
	 * @author Mousebomb
	 */
	public class TSLevel extends Sprite implements IDispose,IFlyIn
	{
		private var shelf : Shelf;
		private var selectedId : int;
		/**
		 * 记录要闪光的图
		 */
		public static var _shinePicId : int;
		/**
		 * 最后翻阅到的页
		 */
		private static var lastPage : int = 0;

		private var ui :UITSLevel;
		public function TSLevel(shinePicId : int = undefined)
		{
			_shinePicId = shinePicId;
			ui = new UITSLevel();
			addChild(ui);

			shelf = new Shelf();
			shelf.x = 100;
			shelf.y = 250;
			//
			var pageBtnH : Number = ui.nextBtn.height;
			var pageBtnOffsetY : Number = pageBtnH / 2;
			var shelfH : Number = GameConf.VISIBLE_SIZE_H_MINUS_AD - (shelf.y-102) - pageBtnH - 50;
			ui.replayBtn.y = ui.prevBtn.y = ui.nextBtn.y = GameConf.VISIBLE_SIZE_H - 120 - pageBtnOffsetY;
			//
			var rows :int = int(shelfH / 206 );
			shelf.autoConfig(620, shelfH, 181, 206, 3, rows, ThumbTitleLevelBtn, addLiCallback);

			ui.addChild(shelf);
			//
			shelf.setList(GameConf.TS_LIST_IDS);
			if(lastPage>0) shelf.showPage(lastPage);

			if (GameConf.TS_LIST_IDS.length > rows * 3) {
				//
				ui.prevBtn.addEventListener(MouseEvent.CLICK, onPrevBtn);
				ui.nextBtn.addEventListener(MouseEvent.CLICK, onNextBtn);
			} else {
				ui.removeChild(ui.prevBtn);
				ui.removeChild(ui.nextBtn);
			}
			//
			ui.moreBtn.visible = AoaoBridge.isMoreBtnVisible;
			ui.moreBtn.addEventListener(MouseEvent.CLICK, onMoreClick);
			ui.backBtn.addEventListener(MouseEvent.CLICK, onBackClick);
			ui.replayBtn.addEventListener(MouseEvent.CLICK, onReplayClick);

		}

		private function onMoreClick(event : MouseEvent) : void {
			AoaoBridge.gengDuo(this);
		}

		private function onBackClick(event : MouseEvent) : void {
			SoundMan.playSfx(SoundMan.BTN);
			YiZhiDaQuan.instance.replaceScene(new YZSelectGame());
		}

		private function onReplayClick(event : MouseEvent) : void
		{
			new TSRUSureView(this, confirmReplay);
			SoundMan.playSfx(SoundMan.BTN);
		}

		private function confirmReplay() : void
		{
			TSPaintedModel.getInstance().reset();
			_shinePicId = undefined;
			shelf.showPage(shelf.curPage);
		}

		private function validatePageBtns() : void
		{
			ui.prevBtn.mouseEnabled = shelf.curPage > 1;
			ui.prevBtn.alpha = ui.prevBtn.mouseEnabled ? 1.0 : 0.7;
			ui.nextBtn.mouseEnabled = shelf.curPage < shelf.totalPage;
			ui.nextBtn.alpha = ui.nextBtn.mouseEnabled ? 1.0 : 0.7;
		}

		private function onNextBtn(event : MouseEvent) : void {
			SoundMan.playSfx(SoundMan.BTN);
			shelf.nextPage();
			validatePageBtns();
			lastPage = shelf.curPage;
		}

		private function onPrevBtn(event : MouseEvent) : void {
			SoundMan.playSfx(SoundMan.BTN);
			shelf.prevPage();
			validatePageBtns();
			lastPage = shelf.curPage;
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
			var _painted : TSPaintedModel = TSPaintedModel.getInstance();
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
			lastPage = shelf.curPage;
			YiZhiDaQuan.instance.replaceScene(new TSPainting(selectedId));
			this.mouseEnabled = this.mouseChildren = false;
            SoundMan.playSfx(SoundMan.BTN);
		}

		public function flyIn() : void
		{
//			this.y = -GameConf.VISIBLE_SIZE_H;
//			TweenLite.to(this ,0.5 , {y:0 , ease:Back.easeOut ,onComplete:onFlyInComp});
		}

		private function onFlyInComp() : void
		{
		}

		public function dispose() : void
		{
		}
	}
}
