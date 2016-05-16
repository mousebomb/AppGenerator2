/**
 * Created by rhett on 14-7-19.
 */
package org.mousebomb.zhaocha
{
	import org.mousebomb.zhaocha.gamewin.UIGameWinMediator;
	import org.mousebomb.zhaocha.common.SceneEvent;
	import org.mousebomb.zhaocha.common.SceneReplaceCmd;
	import org.mousebomb.zhaocha.game.GameAllWinCmd;
	import org.mousebomb.zhaocha.game.GameDataModel;
	import org.mousebomb.zhaocha.game.GameEvent;
	import org.mousebomb.zhaocha.game.GameWinCmd;
	import org.mousebomb.zhaocha.game.UIGameMediator;
	import org.mousebomb.zhaocha.level.LevelModel;
	import org.mousebomb.zhaocha.level.LevelSelectCmd;
	import org.mousebomb.zhaocha.level.LevelSelectEvent;
	import org.mousebomb.zhaocha.level.UILevelMediator;
	import org.mousebomb.zhaocha.welcome.UIWelcomeMediator;
	import org.robotlegs.base.ContextEvent;
	import org.robotlegs.mvcs.Context;

	import flash.display.DisplayObjectContainer;

	public class GameContext extends Context
	{
		public function GameContext(v : DisplayObjectContainer)
		{
			super(v);
		}

		override public function startup() : void
		{
			injector.mapSingleton(GameDataModel);
			injector.mapSingleton(LevelModel);

			mediatorMap.mapView(UIWelcome, UIWelcomeMediator);
			mediatorMap.mapView(UILevel, UILevelMediator);
			mediatorMap.mapView(UIGame, UIGameMediator);
			mediatorMap.mapView(UIGameWin, UIGameWinMediator);

			commandMap.mapEvent(ContextEvent.STARTUP_COMPLETE, StartupCompleteCmd);
			commandMap.mapEvent(SceneEvent.SCENE_REPLACE, SceneReplaceCmd);
			commandMap.mapEvent(LevelSelectEvent.LEVEL_SELECTED, LevelSelectCmd);
			commandMap.mapEvent(GameEvent.GAME_ALL_WIN, GameAllWinCmd);
			commandMap.mapEvent(GameEvent.GAME_WIN, GameWinCmd);

			super.startup();
		}
	}
}
