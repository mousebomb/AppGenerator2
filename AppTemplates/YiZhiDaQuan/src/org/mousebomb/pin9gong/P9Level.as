package org.mousebomb.pin9gong
{

	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;

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
	public class P9Level extends Sprite  implements IDispose,IFlyIn
	{
		private var ui : UIP9Level;

		public function P9Level()
		{
			ui = new UIP9Level();
			addChild(ui);

			shelf = new Shelf();
			shelf.x = 100;
			shelf.y = 250;
			//
			var pageBtnH : Number = ui.nextBtn.height;
			var pageBtnOffsetY : Number = pageBtnH / 2;
			var shelfH : Number = GameConf.VISIBLE_SIZE_H_MINUS_AD - (shelf.y-102) - pageBtnH - 50;
			ui.prevBtn.y = ui.nextBtn.y = GameConf.VISIBLE_SIZE_H - 120 - pageBtnOffsetY;
			//
			var sample : ThumbLevelBtn = new ThumbLevelBtn();
			loaderFixW = sample.m.width;
			loaderFixH = sample.m.height;
			var rows :int = int(shelfH / 206 );
			shelf.autoConfig(620, shelfH, sample.width, sample.height, 3, rows, ThumbLevelBtn, onAddLi);

			ui.addChild(shelf);
			//
			var levelModel : P9LevelModel = P9LevelModel.getInstance();
			levelModel.initAllLevels();
			shelf.setList(levelModel.p9Levels);
			
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
			ui.backBtn.addEventListener(MouseEvent.CLICK, onBackClick);
		}
		private function onBackClick(event : MouseEvent) : void {
			SoundMan.playSfx(SoundMan.BTN);
			YiZhiDaQuan.instance.replaceScene(new YZSelectGame());
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

		private function onAddLi(li : ThumbLevelBtn, vo : P9LevelVO) : void
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
			var file:File =	P9LevelModel.getLevelImageFile(vo.level);
			var loader:Loader = new Loader();
			loader.load( new URLRequest( file.url ) );
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComp);
			li.addChild(loader);
			loader.mask = li.m;
			var bounds : Rectangle = li.m.getBounds(li);
			loader.x = bounds.x;
			loader.y = bounds.y;
			//0代表没加载完
			loadingDic[loader] = 0;
		}

		private var loaderFixW : Number;
		private var loaderFixH : Number;

		private function onLoadComp( event:Event ):void
		{
			var loaderInfo :LoaderInfo = event.target as LoaderInfo;
			P9Game.fixSize(loaderInfo.loader,loaderFixW,loaderFixH,true);
			loadingDic[loaderInfo.loader] = 1;
		}

		private function onLiUp(event : MouseEvent) : void
		{
			var li : ThumbLevelBtn = event.currentTarget as ThumbLevelBtn;
			var level :int =  (li.vo as P9LevelVO).level;
			P9LevelModel.getInstance().level = level;
			YiZhiDaQuan.instance.replaceScene( new P9Game() );
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
