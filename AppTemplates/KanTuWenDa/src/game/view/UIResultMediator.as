package game.view {
	import game.AoaoGame;
	import game.model.GameDataModel;
	import game.model.LevelModel;
	import game.model.TimuModel;

	import org.mousebomb.GameConf;
	import org.mousebomb.SoundMan;
	import org.robotlegs.mvcs.Mediator;

	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	/**
	 * @author Mousebomb
	 */
	public class UIResultMediator extends Mediator
	{

		public function UIResultMediator()
		{
		}

		[Inject]
		public var gameData : GameDataModel;
		[Inject]
		public var timuModel:TimuModel;
		[Inject]
		public var levelModel:LevelModel;

		override public function onRegister() : void
		{
			//
			var ui : UIResult = viewComponent as UIResult;
			ui.x = GameConf.VISIBLE_SIZE_W / 2;
			ui.left.timeTf1.text = gameData.resultVO.flyTime[0].toFixed(1);
			ui.left.timeTf2.text = gameData.resultVO.flyTime[1].toFixed(1);
			ui.left.timeTf3.text = gameData.resultVO.flyTime[2].toFixed(1);
			ui.left.timeTf4.text = gameData.resultVO.flyTime[3].toFixed(1);
			ui.left.myPrize.y = gameData.resultVO.myGrade * 122.4;
			// 各个鸟的形象
			for (var i : int = 0; i < 4; i++)
			{
				var avatarClazz : Class = gameData.resultVO.birdClass[i] as Class;
				var avatar : MovieClip = new avatarClazz();
//				avatar.scaleX = -1.0;
				avatar.x = 350;
				avatar.y = 123 * i + 60;
				ui.left.addChild(avatar);
			}
			// 只有第一名是玩家才有star
			if(gameData.resultVO.isWinner)
			{
				ui.left.star1.visible = gameData.resultVO.star>0;
				ui.left.star2.visible = gameData.resultVO.star>1;
				ui.left.star3.visible = gameData.resultVO.star>2;
			}
			// 右侧
			// 胜利与否
			ui.right.success.visible = gameData.resultVO.isWinner;
			ui.right.fail.visible = !gameData.resultVO.isWinner;
			// 按钮
			ui.right.levelBtn.addEventListener(MouseEvent.CLICK, onBackClick);
			ui.right.playBtn.addEventListener(MouseEvent.CLICK, onPlayClick);
			ui.right.nextBtn.addEventListener(MouseEvent.CLICK, onNextClick);
			ui.right.nextBtn.visible = (gameData.resultVO.isWinner && gameData.curLevel<levelModel.levelCount);
			// 回答的效果汇总
			ui.right.numPerMinTf.text = gameData.resultVO.numPerMin.toFixed(1);
			ui.right.correctPerTf.text = gameData.resultVO.correctPer.toFixed(1);

			// iPad适配
			if (GameConf.WH_RATE < GameConf.WH_RATE_IPHONE4)
			{
				var eadgeLeft : Number = -GameConf.VISIBLE_SIZE_W / 2;
				var eadgeRight : Number = GameConf.VISIBLE_SIZE_W / 2;
				var scale:Number = GameConf.VISIBLE_SIZE_W / (ui.left.width+ui.right.width+10);
				ui.left.scaleX = ui.left.scaleY = scale;
				ui.right.scaleX = ui.right.scaleY = scale;
				ui.left.x = eadgeLeft;
				ui.right.x = eadgeRight;
			}
			
			//
			if(!CONFIG::DEBUG)
				{
					AoaoBridge.interstitial(contextView);
				}
		}


		private function onPlayClick(event : MouseEvent) : void
		{
			SoundMan.playSfx(SoundMan.BTN);
			dispatch(new SceneEvent(SceneEvent.SCENE_REPLACE, UIGameScene));
		}

		private function onNextClick(event : MouseEvent) : void
		{
			SoundMan.playSfx(SoundMan.BTN);
			if (gameData.curLevel < levelModel.levelCount) gameData.curLevel += 1;
			dispatch(new SceneEvent(SceneEvent.SCENE_REPLACE, UIGameScene));
		}

		private function onBackClick(event : MouseEvent) : void
		{
			SoundMan.playSfx(SoundMan.BTN);
			dispatch(new SceneEvent(SceneEvent.SCENE_REPLACE, UIWelcome));
		}
	}
}
