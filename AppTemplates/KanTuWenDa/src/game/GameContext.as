package game {
	import game.cmd.GamePauseCmd;
	import game.cmd.GameReplayCmd;
	import game.cmd.SceneReplaceCmd;
	import game.cmd.StartupCmd;
	import game.model.DailyResultModel;
	import game.model.GameDataModel;
	import game.model.LevelModel;
	import game.model.TimuModel;
	import game.service.TimuService;
	import game.view.SceneEvent;
	import game.view.UICalendarMediator;
	import game.view.UIGameSceneMediator;
	import game.view.UIHelpMediator;
	import game.view.UIHoverMenuMediator;
	import game.view.UILevelMediator;
	import game.view.UIResultMediator;
	import game.view.UIWelcomeMediator;

	import org.robotlegs.mvcs.Context;

	import flash.display.DisplayObjectContainer;
	import flash.system.Capabilities;

	/**
	 * @author Mousebomb
	 */
	public class GameContext extends Context
	{
		public function GameContext(contextView : DisplayObjectContainer = null, autoStartup : Boolean = true)
		{
			super(contextView, autoStartup);
		}

		override public function startup() : void
		{
			var isIOS : Boolean = Capabilities.os.indexOf("iPhone") != -1;
			if (Capabilities.os.indexOf("iPad") != -1)
				isIOS = true;

			//
			mediatorMap.mapView(UIWelcome, UIWelcomeMediator);
			mediatorMap.mapView(UIGameScene, UIGameSceneMediator);
			mediatorMap.mapView(UIHelp, UIHelpMediator);
			mediatorMap.mapView(UILevel, UILevelMediator);
			mediatorMap.mapView(UIResult, UIResultMediator);
			mediatorMap.mapView(UIHoverMenu, UIHoverMenuMediator);
			mediatorMap.mapView(UICalendar, UICalendarMediator);
			//
			injector.mapSingleton(TimuService);
			injector.mapSingleton(GameDataModel);
			injector.mapSingleton(LevelModel);
			injector.mapSingleton(TimuModel);
			injector.mapSingleton(DailyResultModel);

			commandMap.mapEvent(SceneEvent.SCENE_REPLACE, SceneReplaceCmd);
			commandMap.mapEvent(SceneEvent.SCENE_REQUEST_PAUSE, GamePauseCmd);
			commandMap.mapEvent(SceneEvent.SCENE_REQUEST_CONTINUE, GamePauseCmd);
			commandMap.mapEvent(SceneEvent.SCENE_REQUEST_REPLAY, GameReplayCmd);

			commandMap.execute(StartupCmd);
		}
	}
}
