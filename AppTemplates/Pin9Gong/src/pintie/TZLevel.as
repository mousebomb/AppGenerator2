package pintie
{
    import com.aoaogame.sdk.adManager.MyAdManager;

	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.URLRequest;

	import flash.utils.Dictionary;

	import org.mousebomb.GameConf;
	import org.mousebomb.IFlyIn;
	import org.mousebomb.SoundMan;
	import org.mousebomb.interfaces.IDispose;
	import org.mousebomb.ui.Shelf;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;

	import pintie.PTGame;

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
			var rect : Rectangle = new Rectangle(15, 98, 610, 760);
			shelf.x = 15;
			shelf.y = 98;
			//
			var shelfAndPageBtnH : Number = GameConf.VISIBLE_SIZE_H - 100 - shelf.y;
			var pageBtnH : Number = ui.nextBtn.height;
			var pageBtnOffsetY : Number = pageBtnH / 2;
			var shelfH : Number = shelfAndPageBtnH - pageBtnH - 50;
			ui.prevBtn.y = ui.nextBtn.y = GameConf.VISIBLE_SIZE_H - 120 - pageBtnOffsetY;
			//
			var sample : LevelItem = new LevelItem();
			loaderFixW = sample.m.width;
			loaderFixH = sample.m.height;
			shelf.autoConfig(610, shelfH, sample.width, sample.height, 3, 3, LevelItem, onAddLi);

			ui.addChild(shelf);
			//
			var levelModel : LevelModel = LevelModel.getInstance();
			levelModel.initAllLevels();
			shelf.setList(levelModel.levels);
			
			if(levelModel.levelCount > shelf.pageCount){
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
		}
        private function onMoreClick(event : MouseEvent) : void {
            AoaoBridge.gengDuo(this);
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

		private function onAddLi(li : LevelItem, vo : LevelVO) : void
		{
			if (vo.canPlay)
			{
				li.addEventListener(MouseEvent.MOUSE_UP, onLiUp);
			}
			else
			{
				li.alpha = 0.5;
			}
			li.vo = vo;
			// loader
			var file:File =	LevelModel.getLevelImageFile(vo.level);
			var loader:Loader = new Loader();
			loader.load( new URLRequest( file.url ) );
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComp);
			li.addChild(loader);
			loader.mask = li.m;
			loader.x = li.m.x;
			loader.y = li.m.y;
			//0代表没加载完
			loadingDic[loader] = 0;
		}

		private var loaderFixW : Number;
		private var loaderFixH : Number;

		private function onLoadComp( event:Event ):void
		{
			var loaderInfo :LoaderInfo = event.target as LoaderInfo;
			PTGame.fixSize(loaderInfo.loader,loaderFixW,loaderFixH,true);
			loadingDic[loaderInfo.loader] = 1;
		}

		private function onLiUp(event : MouseEvent) : void
		{
			var li : LevelItem = event.currentTarget as LevelItem;
			var level :int =  (li.vo as LevelVO).level;
			LevelModel.getInstance().level = level;
			PinTie.instance.replaceScene( new PTGame() );
		}

		private var loadingDic :Dictionary = new Dictionary(true);

		public function dispose() : void
		{
			// 取消加载
			for  ( var loader:Loader in loadingDic )
			{
				var val : int = loadingDic[loader];
				if(val == 1 )
				{
					loader.unload();
				}else{
					try{loader.close();}catch(e:*){}
				}
			}
		}

		public function flyIn() : void
		{
		}
	}
}
