package org.mousebomb.jianbihua {
	import org.mousebomb.GameConf;
	import org.mousebomb.IFlyIn;
	import org.mousebomb.SoundMan;
	import org.mousebomb.interfaces.IDispose;
	import org.mousebomb.ui.Shelf;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;

	import yizhidaquan.YZSelectGame;
	import yizhidaquan.YiZhiDaQuan;

	/**
	 * @author rhett
	 */
	public class JBHLevel extends Sprite  implements IDispose,IFlyIn {
		private var ui : UIJBHLevel;
		private static var lastPage : int = 0;

		public function JBHLevel() {
			ui = new UIJBHLevel();
			addChild(ui);

			shelf = new Shelf();
			var rect : Rectangle = new Rectangle(15, 138, 610, 720);
			shelf.x = 100;
			shelf.y = 250;
			//
			var pageBtnH : Number = ui.nextBtn.height;
			var pageBtnOffsetY : Number = pageBtnH / 2;
			var shelfH : Number = GameConf.VISIBLE_SIZE_H_MINUS_AD - (shelf.y-102) - pageBtnH - 50;
			ui.prevBtn.y = ui.nextBtn.y = GameConf.VISIBLE_SIZE_H - 120 - pageBtnOffsetY;
			//
			var rows :int = int(shelfH / 206 );
			shelf.autoConfig(620, shelfH, 181, 206, 3, rows, ThumbTitleLevelBtn, onAddLi);

			ui.addChild(shelf);
			//
			var levelModel : JBHLevelModel = JBHLevelModel.getInstance();
			levelModel.initAllLevels();
			shelf.setList(levelModel.levels);
			if(lastPage>0) shelf.showPage(lastPage);

			if (levelModel.levels.length > rows * 3) {
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
		}

		private function onMoreClick(event : MouseEvent) : void {
			AoaoBridge.gengDuo(this);
		}

		private function onBackClick(event : MouseEvent) : void {
			SoundMan.playSfx(SoundMan.BTN);
			YiZhiDaQuan.instance.replaceScene(new YZSelectGame());
		}

		private var shelf : Shelf;

		private function onNextBtn(event : MouseEvent) : void {
			SoundMan.playSfx(SoundMan.BTN);
			shelf.nextPage();
			lastPage = shelf.curPage;
		}

		private function onPrevBtn(event : MouseEvent) : void {
			SoundMan.playSfx(SoundMan.BTN);
			shelf.prevPage();
			lastPage = shelf.curPage;
		}

		private function onAddLi(li : ThumbTitleLevelBtn, level : int) : void {
			li.titles.gotoAndStop(level);
			li.mouseChildren = false;
			li.addEventListener(MouseEvent.MOUSE_UP, onLiUp);
			li.level = level;
			var pictureClassName : String = "JbhPic" + level;
try{			var clazz : Class = getDefinitionByName(pictureClassName) as Class;
			var thumb : Sprite = new clazz();
			var sw : Number = (li.m.width-20) / thumb.width ;
			var sh : Number = (li.m.height-20) / thumb.height;
			var scale :Number = (sw > sh ? sh : sw);
			thumb.scaleX = thumb.scaleY = scale;
			thumb.x = li.m.x ;
			thumb.y = li.m.y ;
			li.addChild(thumb);
			thumb.mask = li.m;
}catch(e:*){}
		}

		private function onLiUp(event : MouseEvent) : void {
			SoundMan.playSfx(SoundMan.BTN);
			var li : ThumbTitleLevelBtn = event.currentTarget as ThumbTitleLevelBtn;
			JBHLevelModel.getInstance().level = li.level;
			YiZhiDaQuan.instance.replaceScene(new JBHGame());
		}

		public function dispose() : void {
		}

		public function flyIn() : void {
		}
	}
}
