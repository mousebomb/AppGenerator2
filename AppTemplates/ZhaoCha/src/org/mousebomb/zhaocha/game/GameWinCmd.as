package org.mousebomb.zhaocha.game
{
	import org.mousebomb.SoundMan;
	import org.mousebomb.zhaocha.level.LevelModel;
	import org.robotlegs.mvcs.Command;

	import flash.utils.setTimeout;

	/**
	 * @author rhett
	 */
	public class GameWinCmd extends Command
	{
		
		[Inject]
		public var e:GameEvent;
		
		[Inject]
		public var gameDataModel:GameDataModel;
		
		[Inject]
		public var levelModel:LevelModel;
		public function GameWinCmd()
		{
		}

		override public function execute() : void
		{
			SoundMan.playSfx(SoundMan.PRIZE);
			levelModel.saveLevel(e.level, 1);
			if(levelModel.levelCount>e.level)
			{
                if(!CONFIG::DEBUG)
                {
                    AoaoBridge.interstitial(contextView);
                }
				// 还有下一关
				setTimeout(function():void{gameDataModel.gotoLevel(e.level+1);
					}, 2000);
			}else{
				// 通关了
				var winAllEvent : GameEvent = new GameEvent(GameEvent.GAME_ALL_WIN);
				dispatch(winAllEvent);
			}
		}

	}
}
