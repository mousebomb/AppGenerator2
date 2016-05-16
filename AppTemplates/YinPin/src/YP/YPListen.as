/**
 * Created by rhett on 15/6/12.
 */
package YP
{

	import com.aoaogame.sdk.adManager.MyAdManager;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;

	import flash.display.Loader;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;

	import org.mousebomb.GameConf;
	import org.mousebomb.SoundMan;

	import org.mousebomb.interfaces.IDispose;

	public class YPListen extends Sprite implements IDispose
	{
		private var ui : ListenUI;
		public function YPListen(vo :MusicInfoVO)
		{
			super();
			ui = new ListenUI();
			ui.x = (GameConf.VISIBLE_SIZE_W - GameConf.DESIGN_SIZE_W)/2;
			addChild(ui);
			ui.backBtn.addEventListener(MouseEvent.CLICK, onBackClick);
			ui.restartBtn.addEventListener(MouseEvent.CLICK,onRestartClick);
			ui.playBtn.addEventListener(MouseEvent.CLICK,onPausePlayClick);
			ui.stopBtn.addEventListener(MouseEvent.CLICK,onPausePlayClick);
			ui.stopBtn.visible = true;ui.playBtn.visible = false;
			//
			ui.moreBtn.visible = AoaoBridge.isMoreBtnVisible;
			ui.moreBtn.addEventListener(MouseEvent.CLICK, onMoreClick);
            //
            ui.titleTf.text = vo.mp3Name;
			//
			loadThumb(vo.thumbFile);
			discAnim(true);

			if( !CONFIG::DESKTOP )
			{
				AoaoBridge.banner(this);
			}
		}
		private function onMoreClick(event : MouseEvent) : void
		{
			AoaoBridge.gengDuo(this);
			SoundMan.playSfx(SoundMan.BTN);
		}

		private function onPausePlayClick( event:MouseEvent ):void
		{
			Player.getInstance().pausePlay();
			switch(event.currentTarget)
			{
				case ui.playBtn:
					ui.playBtn.visible = false ;
					ui.stopBtn.visible = true ;
					discAnim(true);
					break;
				case ui.stopBtn:
					ui.playBtn.visible = true ;
					ui.stopBtn.visible = false;
					discAnim(false);

					break;
			}
			SoundMan.playSfx(SoundMan.BTN);

		}

		private function onRestartClick( event:MouseEvent ):void
		{
			Player.getInstance().reset();
			ui.playBtn.visible = false ;
			ui.stopBtn.visible = true ;
			SoundMan.playSfx(SoundMan.BTN);
			discAnim(true);
		}

		private function discAnim( on:Boolean ):void
		{
			if(on)TweenMax.to( ui.disc,3,{rotation:360 ,repeat:int.MAX_VALUE,ease:Linear.easeNone } );
			else TweenMax.killTweensOf(ui.disc);
		}

		private function onBackClick( event:MouseEvent ):void
		{
			if( !CONFIG::DESKTOP )
			{
				AoaoBridge.interstitial(this);
			}
			Game.instance.replaceScene(new YPSelect());
			SoundMan.playSfx(SoundMan.BTN);
		}


		/* ------------------- # DISC # ---------------- */

		private var imgLoader:Loader;

		public function loadThumb(imgFile :File):void
		{
			imgLoader = new Loader();
			imgLoader.contentLoaderInfo.addEventListener( Event.COMPLETE, onThumbLoaded );
			imgLoader.load( new URLRequest( imgFile.url ) );
			trace("Disc/loadThumb()",imgFile.url);
		}

		private function onThumbLoaded( event:Event ):void
		{
			imgLoader.width = ui.disc.img.width;
			imgLoader.height = ui.disc.img.height;
			ui.disc.img.addChild( imgLoader );
		}


		public function dispose():void
		{
		}
	}
}
