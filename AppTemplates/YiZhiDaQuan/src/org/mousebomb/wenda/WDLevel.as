package org.mousebomb.wenda
{

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;

	import org.mousebomb.GameConf;
	import org.mousebomb.IFlyIn;
	import org.mousebomb.SoundMan;
	import org.mousebomb.interfaces.IDispose;
	import org.mousebomb.ui.Shelf;

	import yizhidaquan.YZSelectGame;

	import yizhidaquan.YiZhiDaQuan;

	/**
	 * @author rhett
	 */
	public class WDLevel extends Sprite  implements IDispose,IFlyIn
	{
		private var ui : UITZLevel;

		public function WDLevel()
		{
			ui = new UITZLevel();
			addChild(ui);

			shelf = new Shelf();
			var rect : Rectangle = new Rectangle(15, 138, 610, 720);
			shelf.x = 15;
			shelf.y = 138;
			//
			var shelfAndPageBtnH : Number = GameConf.VISIBLE_SIZE_H - 100 - shelf.y;
			var pageBtnH : Number = ui.nextBtn.height;
			var pageBtnOffsetY : Number = pageBtnH / 2;
			var shelfH : Number = shelfAndPageBtnH - pageBtnH - 50;
			ui.prevBtn.y = ui.nextBtn.y = GameConf.VISIBLE_SIZE_H - 120 - pageBtnOffsetY;
			//
			var sample : DisplayObject = new NumLevelBtn();
			shelf.autoConfig(610, shelfH, sample.width, sample.height, 5, 6, NumLevelBtn, onAddLi);

			ui.addChild(shelf);
			//
			var levelModel : WDLevelModel = WDLevelModel.getInstance();
			levelModel.initAllLevels();
			shelf.setList(levelModel.wdLevels);
			
			if(levelModel.levelCount > 30){
			//
			ui.prevBtn.addEventListener(MouseEvent.CLICK, onPrevBtn);
			ui.nextBtn.addEventListener(MouseEvent.CLICK, onNextBtn);
			}else{
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
		

		private function onBackClick(event : MouseEvent) : void
		{
			SoundMan.playSfx(SoundMan.BTN);
			YiZhiDaQuan.instance.replaceScene(new YZSelectGame());
		}

		private var shelf : Shelf;

		private function onNextBtn(event : MouseEvent) : void
		{
			SoundMan.playSfx(SoundMan.BTN);
			shelf.nextPage();
		}

		private function onPrevBtn(event : MouseEvent) : void
		{
			SoundMan.playSfx(SoundMan.BTN);
			shelf.prevPage();
		}

		private function onAddLi(li : NumLevelBtn, vo : WDLevelVO) : void
		{
			li.levelTf.text = vo.level.toString();
			li.levelTf.mouseEnabled = false;
			var colorTransform : ColorTransform = new ColorTransform();
			colorTransform.color = 0xaaaaaa;
			if (vo.canPlay)
			{
				li.addEventListener(MouseEvent.MOUSE_UP, onLiUp);
			}
			else
			{
				li.alpha = 0.5;
			}
			li.vo = vo;
		}

		private function onLiUp(event : MouseEvent) : void
		{
			SoundMan.playSfx(SoundMan.BTN);
			var li : NumLevelBtn = event.currentTarget as NumLevelBtn;
			var level :int =  (li.vo as WDLevelVO).level;
			WDLevelModel.getInstance().level = level;
			YiZhiDaQuan.instance.replaceScene( new WDGame() );
		}

		public function dispose() : void
		{
		}

		public function flyIn() : void
		{
		}
	}
}
