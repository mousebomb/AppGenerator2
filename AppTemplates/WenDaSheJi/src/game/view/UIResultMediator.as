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
			// 右侧
			// 胜利与否
			ui.success.visible = gameData.resultVO.isWinner;
			ui.fail.visible = !gameData.resultVO.isWinner;
			// 按钮
			ui.levelBtn.addEventListener(MouseEvent.CLICK, onBackClick);
			ui.playBtn.addEventListener(MouseEvent.CLICK, onPlayClick);
			ui.nextBtn.addEventListener(MouseEvent.CLICK, onNextClick);
			ui.nextBtn.visible = (gameData.resultVO.isWinner && gameData.curLevel<levelModel.levelCount);
			// 回答的效果汇总
			ui.numPerMinTf.text = gameData.resultVO.numPerMin.toFixed(1);
			ui.correctPerTf.text = gameData.resultVO.correctPer.toFixed(1);
            // 星
                ui.star1.visible = gameData.resultVO.star>0;
                ui.star2.visible = gameData.resultVO.star>1;
                ui.star3.visible = gameData.resultVO.star>2;
//			for (i = 1; i <= 5 && i <= gameData.resultVO.wrongQnA.length; i++)
//			{
//				(ui.right['wrongTf' + i] as TextField).text = (gameData.resultVO.wrongQnA[i - 1]);
//				(ui.right['wrongTf' + i] as TextField).mouseEnabled = false;
//			}
//			for (; i <= 5; i++)
//			{
//				(ui.right['wrongTf' + i] as TextField).text = "";
//				(ui.right['wrongTf' + i] as TextField).mouseEnabled = false;
//			}
			var wrongText : String="";
			for(var i:int =1;i<=gameData.resultVO.wrongQnA.length ; i++)
			{
				wrongText += gameData.resultVO.wrongQnA[i-1]+"\n";
			}
			ui.wrongTf.text = wrongText;

			/*// iPad适配
			if (GameConf.WH_RATE < GameConf.WH_RATE_IPHONE4)
			{
				var eadgeLeft : Number = -GameConf.VISIBLE_SIZE_W / 2;
				var eadgeRight : Number = GameConf.VISIBLE_SIZE_W / 2;
				var scale:Number = GameConf.VISIBLE_SIZE_W / (ui.left.width+ui.right.width+10);
				ui.left.scaleX = ui.left.scaleY = scale;
				ui.right.scaleX = ui.right.scaleY = scale;
				ui.left.x = eadgeLeft;
				ui.right.x = eadgeRight;
			}*/
			
			//
			AoaoBridge.interstitial(contextView);
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
