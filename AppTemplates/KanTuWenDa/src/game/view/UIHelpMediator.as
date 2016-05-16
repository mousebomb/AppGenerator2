package game.view
{
	import org.mousebomb.GameConf;
	import org.mousebomb.SoundMan;
	import org.robotlegs.mvcs.Mediator;

	import flash.events.MouseEvent;

	/**
	 * @author Mousebomb
	 */
	public class UIHelpMediator extends Mediator
	{
		public function UIHelpMediator()
		{
		}

		override public function onRegister() : void
		{
			var ui : UIHelp = (viewComponent as UIHelp);
			ui.x = GameConf.VISIBLE_SIZE_W / 2;
			ui.backBtn.addEventListener(MouseEvent.CLICK, onBackClick);

			// iPad适配
			if (GameConf.WH_RATE < GameConf.WH_RATE_IPHONE4)
			{
				var eadgeLeft : Number = -GameConf.VISIBLE_SIZE_W / 2;
				var scale : Number = GameConf.VISIBLE_SIZE_W / ui.hp.width;
				ui.hp.scaleX = ui.hp.scaleY = scale;
				if (ui.backBtn.x < eadgeLeft + 62)
					ui.backBtn.x = eadgeLeft + 62;
			}
		}

		private function onBackClick(event : MouseEvent) : void
		{
			SoundMan.playSfx(SoundMan.BTN);
			dispatch(new SceneEvent(SceneEvent.SCENE_REPLACE, UIWelcome));
		}
	}
}
