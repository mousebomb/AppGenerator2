package game.view {
	import game.AoaoGame;

	import org.mousebomb.GameConf;
	import org.mousebomb.SoundMan;
	import org.robotlegs.mvcs.Mediator;

	import flash.events.MouseEvent;

	/**
	 * @author Mousebomb
	 */
	public class UIHoverMenuMediator extends Mediator
	{
		public function UIHoverMenuMediator()
		{
		}

		override public function onRegister() : void
		{
			var ui : UIHoverMenu = viewComponent as UIHoverMenu;
			ui.x = GameConf.VISIBLE_SIZE_W / 2;
			ui.y = GameConf.VISIBLE_SIZE_H / 2;

			ui.playBtn.addEventListener(MouseEvent.CLICK, onPlayBtnClick);
			ui.replayBtn.addEventListener(MouseEvent.CLICK, onReplayBtnClick);
			ui.levelBtn.addEventListener(MouseEvent.CLICK, onLevelBtnClick);
		}

		private function onPlayBtnClick(event : MouseEvent) : void
		{
			SoundMan.playSfx(SoundMan.BTN);
			dispatch(new SceneEvent(SceneEvent.SCENE_REQUEST_CONTINUE, null));
			var ui : UIHoverMenu = viewComponent as UIHoverMenu;
			ui.parent.removeChild(ui);
		}

		private function onReplayBtnClick(event : MouseEvent) : void
		{
			SoundMan.playSfx(SoundMan.BTN);
			dispatch(new SceneEvent(SceneEvent.SCENE_REQUEST_REPLAY, null));
			var ui : UIHoverMenu = viewComponent as UIHoverMenu;
			ui.parent.removeChild(ui);
		}

		private function onLevelBtnClick(event : MouseEvent) : void
		{
			SoundMan.playSfx(SoundMan.BTN);
			dispatch(new SceneEvent(SceneEvent.SCENE_REPLACE, UIWelcome));
			var ui : UIHoverMenu = viewComponent as UIHoverMenu;
			ui.parent.removeChild(ui);
			
			//
			if(!CONFIG::DEBUG)
				{
					AoaoBridge.interstitial(contextView);
				}
		}
	}
}
