/**
 * Created by rhett on 14-7-19.
 */
package org.mousebomb.zhaocha.welcome
{
	import org.mousebomb.SoundMan;
	import org.mousebomb.zhaocha.level.LevelModel;

	import flash.events.MouseEvent;

	import org.mousebomb.zhaocha.common.SceneEvent;
	import org.robotlegs.mvcs.Mediator;

	public class UIWelcomeMediator extends Mediator
	{
		public function UIWelcomeMediator()
		{
			super();
		}

		[Inject]
		public var levelModel : LevelModel;

		override public function onRegister() : void
		{
			var ui : UIWelcome = viewComponent as UIWelcome;
			//
			levelModel.initAllLevels();
			ui.totalLevel.text = (levelModel.levelCount - levelModel.levelFinished).toString();
			ui.finishedLevel.text = levelModel.levelFinished.toString();
			// 显示grid
			ui.addEventListener(MouseEvent.CLICK, onClickAnywhere);
		}

		private function onClickAnywhere(event : MouseEvent) : void
		{
        	SoundMan.playSfx(SoundMan.BTN);
			dispatch(new SceneEvent(SceneEvent.SCENE_REPLACE, UILevel));
		}
	}
}
