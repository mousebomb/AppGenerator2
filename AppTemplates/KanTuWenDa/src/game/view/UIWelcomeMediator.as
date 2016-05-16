package game.view {
	import game.AoaoGame;
	import game.model.GameDataModel;

	import com.aoaogame.sdk.adManager.MyAdManager;

	import org.mousebomb.GameConf;
	import org.mousebomb.SoundMan;
	import org.robotlegs.mvcs.Mediator;

	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.net.SharedObject;
	import flash.utils.getDefinitionByName;

	/**
	 * @author Mousebomb
	 */
	public class UIWelcomeMediator extends Mediator
	{
		private var _bird : DisplayObject;

		public function UIWelcomeMediator()
		{
		}

		override public function onRegister() : void
		{
			var ui : UIWelcome = viewComponent as UIWelcome;
			var scaleX : Number = GameConf.VISIBLE_SIZE_W / GameConf.DESIGN_SIZE_W;
			ui.bg.x *= scaleX;
			ui.center.x *= scaleX;
			ui.prevBtn.x *= scaleX;
			ui.nextBtn.x *= scaleX;
			ui.muteBtn.x *= scaleX;
			ui.soundBtn.x *= scaleX;
			ui.helpBtn.x *= scaleX;
			ui.calendarBtn.x *= scaleX;
			ui.startBtn.x *= scaleX;
			ui.title.x *= scaleX;
			ui.moreBtn.x *= scaleX;
			choseBird(getPlayerAvatar());
			ui.prevBtn.addEventListener(MouseEvent.CLICK, onBirdPrev);
			ui.nextBtn.addEventListener(MouseEvent.CLICK, onBirdNext);
			ui.startBtn.addEventListener(MouseEvent.CLICK, onStartClick);
			ui.helpBtn.addEventListener(MouseEvent.CLICK, onHelpClick);
			ui.calendarBtn.addEventListener(MouseEvent.CLICK, onCalClick);
			ui.muteBtn.addEventListener(MouseEvent.CLICK, onMuteClick);
			ui.soundBtn.addEventListener(MouseEvent.CLICK, onMuteClick);
			ui.moreBtn.addEventListener(MouseEvent.CLICK, onMoreClick);
            //
            ui.soundBtn.visible = SoundMan.isMute;
            ui.muteBtn.visible = !SoundMan.isMute;
            //
            ui.moreBtn.visible = (AoaoBridge.isMoreBtnVisible);

		}

		private function onMoreClick(event : MouseEvent) : void
		{
			AoaoBridge.gengDuo(contextView);
		}

		private function onMuteClick(event : MouseEvent) : void
		{
			var ui : UIWelcome = viewComponent as UIWelcome;
			if (event.target == ui.soundBtn)
			{
				SoundMan.isMute = false;
				ui.soundBtn.visible = false;
				ui.muteBtn.visible = true;
			}
			else
			{
				SoundMan.isMute = true;
				ui.soundBtn.visible = true;
				ui.muteBtn.visible = false;
			}
            //
            if(!CONFIG::DEBUG)
            {
                AoaoBridge.banner(contextView);
            }
		}

		public function savePlayerAvatar(id : int) : void
		{
			var so : SharedObject = SharedObject.getLocal(GameConf.LOCAL_SO_NAME);
			so.data['avatar'] = id;
			so.flush();
			so.close();
		}

		public function getPlayerAvatar() : int
		{
			var end : int = 1;
			var so : SharedObject = SharedObject.getLocal(GameConf.LOCAL_SO_NAME);
			if (so.data['avatar']) end = so.data.avatar;
			so.close();
			return end;
		}

		private function onCalClick(event : MouseEvent) : void
		{
			// MyAdManager.showAd();
			SoundMan.playSfx(SoundMan.BTN);
			dispatch(new SceneEvent(SceneEvent.SCENE_REPLACE, UICalendar));
            //
            if(!CONFIG::DEBUG)
            {
                AoaoBridge.banner(contextView);
            }
		}

		private function onHelpClick(event : MouseEvent) : void
		{
			SoundMan.playSfx(SoundMan.BTN);
			dispatch(new SceneEvent(SceneEvent.SCENE_REPLACE, UIHelp));
            //
            if(!CONFIG::DEBUG)
            {
                AoaoBridge.banner(contextView);
            }
		}

		private function onStartClick(event : MouseEvent) : void
		{
			SoundMan.playSfx(SoundMan.BTN);
			dispatch(new SceneEvent(SceneEvent.SCENE_REPLACE, UILevel));
            //
            if(!CONFIG::DEBUG)
            {
                AoaoBridge.banner(contextView);
            }
		}

		[Inject]
		public var gameModel : game.model.GameDataModel;

		private function onBirdNext(event : MouseEvent) : void
		{
			SoundMan.playSfx(SoundMan.BTN);
			if (curBird < birdMax) choseBird(curBird + 1);
			else
			{
				choseBird(birdMin);
			}
		}

		private function onBirdPrev(event : MouseEvent) : void
		{
			SoundMan.playSfx(SoundMan.BTN);
			if (curBird > birdMin) choseBird(curBird - 1);
			else
				choseBird(birdMax);
		}

		Bird1;
		Bird2;
		Bird3;
		Bird4;
		Bird5;
		Bird6;
		private var birdMin : int = 1;
		public static var birdMax : int = 6;
		private var curBird : int = 1;

		private function choseBird(id : int) : void
		{
			var ui : UIWelcome = viewComponent as UIWelcome;
			if (_bird)
			{
				ui.removeChild(_bird);
			}
			var Bird : Class = getDefinitionByName("Bird" + id) as Class;

			_bird = new Bird();
			_bird.scaleX = -1.5;
			_bird.scaleY = 1.5;
			_bird.y = 268 - _bird.height / 2;
			_bird.x = GameConf.VISIBLE_SIZE_W / 2;// + _bird.width / 2;
			curBird = id;
			ui.addChild(_bird);
			gameModel.playerBird.birdId = this.curBird;
			gameModel.playerBird.clazz = Bird;
		}

		override public function onRemove() : void
		{
			savePlayerAvatar(curBird);
		}
	}
}
