package tiezhi
{
	import com.aoaogame.sdk.adManager.MyAdManager;
	import org.mousebomb.IFlyIn;
	import org.mousebomb.SoundMan;
	import org.mousebomb.GameConf;
	import org.mousebomb.interfaces.IDispose;
	import org.mousebomb.ui.Shelf;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;

	/**
	 * @author rhett
	 */
	public class TZLevel extends Sprite  implements IDispose,IFlyIn
	{
		private var ui : UILevel;

		public function TZLevel()
		{
			ui = new UILevel();
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
			var sample : DisplayObject = new LevelBtn();
			shelf.autoConfig(610, shelfH, sample.width, sample.height, 5, 6, LevelBtn, onAddLi);

			ui.addChild(shelf);
			//
			var levelModel : LevelModel = LevelModel.getInstance();
			levelModel.initAllLevels();
			shelf.setList(levelModel.levels);
			
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
			TieZhi.instance.replaceScene(new TZWelcome());
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

		private function onAddLi(li : LevelBtn, vo : LevelVO) : void
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
			var li : LevelBtn = event.currentTarget as LevelBtn;
			var level :int =  (li.vo as LevelVO).level;
			LevelModel.getInstance().level = level;
			TieZhi.instance.replaceScene( new TZGame() );
		}

		public function dispose() : void
		{
		}

		public function flyIn() : void
		{
		}
	}
}
