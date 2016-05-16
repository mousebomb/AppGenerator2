package game.view {
	import game.AoaoGame;
	import game.model.BirdMoveEvent;
	import game.model.DailyResultModel;
	import game.model.GameDataModel;
	import game.model.LevelModel;
	import game.model.event.LevelEvent;
	import game.model.vo.QuestionVO;

	import org.mousebomb.GameConf;
	import org.mousebomb.SoundMan;
	import org.robotlegs.mvcs.Mediator;

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.utils.setTimeout;

	/**
	 * @author Mousebomb
	 */
	public class UIGameSceneMediator extends Mediator
	{
		private var npcBird1 : MovieClip;
		private var npcBird2 : MovieClip;
		private var npcBird3 : MovieClip;
		private var playerBird : MovieClip;
		private var timeoutHandle : uint;
		// 在ui上显示的起点和终点x位置
		public static var finalPosX : Number = 825;
		public static var startPosX : Number = 150;
		public static var totalDistance : Number = finalPosX - startPosX;
		public var curViewportX : Number = 0.0;

		public function UIGameSceneMediator()
		{
		}

		[Inject]
		public var gameData : GameDataModel;
		[Inject]
		public var dailyResultModel : DailyResultModel;
		[Inject]
		public var levelModel:LevelModel;
		
		// 静态的背景层
		static private var gameSceneBg : GameSceneBg;

		override public function onRegister() : void
		{
			var ui : UIGameScene = viewComponent as UIGameScene;
			//
			ui.qp.a1Tf.mouseEnabled = false;
			ui.qp.a2Tf.mouseEnabled = false;
			ui.qp.a3Tf.mouseEnabled = false;
			ui.qp.a4Tf.mouseEnabled = false;
			//
			ui.qp.aBtn1.addEventListener(MouseEvent.CLICK, onAwnserClick);
			ui.qp.aBtn2.addEventListener(MouseEvent.CLICK, onAwnserClick);
			ui.qp.aBtn3.addEventListener(MouseEvent.CLICK, onAwnserClick);
			ui.qp.aBtn4.addEventListener(MouseEvent.CLICK, onAwnserClick);
			//
			ui.qp.speed.gotoAndStop(0);
			//
			ui.pauseBtn.addEventListener(MouseEvent.CLICK, onPauseClick);

			// var scaleX : Number = GameConf.VISIBLE_SIZE_W / GameConf.DESIGN_SIZE_W;
			// ui.pauseBtn.x *= scaleX;
			ui.qp.x = (GameConf.VISIBLE_SIZE_W - ui.qp.width) / 2;


			// iPad适配
			if (GameConf.WH_RATE < GameConf.WH_RATE_IPHONE4)
			{
				var scale:Number = GameConf.VISIBLE_SIZE_W / (ui.qp.width + 40);
				ui.qp.scaleX = ui.qp.scaleY = scale;
				ui.qp.x = 26;
			}
			
			
			// BIRD radar 从10 ~ 208

			ui.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			//
			addContextListener(LevelEvent.LEVEL_START, onLevelStart);
			addContextListener(LevelEvent.QUESTION_CHANGED, onQuestionChange);
			addContextListener(LevelEvent.PLAYER_FINISH, onPlayerFinish);
			addContextListener(BirdMoveEvent.BIRDS_MOVE, onBirdMove);
			addContextListener(BirdMoveEvent.PLAYER_SPEED_CHANGE, onPlayerSpeedChange);
			addContextListener(SceneEvent.SCENE_REQUEST_CONTINUE, onContinue);

			//
			if(gameSceneBg==null) gameSceneBg=new GameSceneBg();
			ui.bg.addChild(gameSceneBg);
			//
			gameData.startLevel();
		}

		private function onContinue(e : SceneEvent) : void
		{
			var ui : UIGameScene = viewComponent as UIGameScene;
			ui.bg.play();
		}

		/**
		 * 暂停
		 */
		private function onPauseClick(event : MouseEvent) : void
		{
			SoundMan.playSfx(SoundMan.BTN);
			var ui : UIGameScene = viewComponent as UIGameScene;
			ui.bg.stop();
			dispatch(new SceneEvent(SceneEvent.SCENE_REQUEST_PAUSE, null));
		}

		private function onPlayerFinish(e : LevelEvent) : void
		{
			SoundMan.playSfx(SoundMan.FINISH);
			var date : Date = new Date();
			dailyResultModel.addToToday(date, gameData.resultVO.totalAnswer, gameData.resultVO.correctAnswer);
			levelModel.saveLevel(gameData.curLevel, gameData.resultVO.star);
			dispatch(new SceneEvent(SceneEvent.SCENE_REPLACE, UIResult));
		}

		private function onPlayerSpeedChange(e : BirdMoveEvent) : void
		{
			var ui : UIGameScene = viewComponent as UIGameScene;
			ui.qp.speed.gotoAndStop(gameData.playerSpeedForShow);
		}

		/**
		 * 鸟移动更新
		 */
		private function onBirdMove(e : BirdMoveEvent) : void
		{
			//
			var oldPlayerBirdX : Number = curViewportX;
			curViewportX = gameData.playerBird.pos - GameConf.VISIBLE_SIZE_W / 2;
			var deltaPlayerX : Number = curViewportX - oldPlayerBirdX;
			// trace('curViewportX: ' + (curViewportX));
			//
			playerBird.x = posToPx(gameData.playerBird.pos);
			npcBird1.x = posToPx(gameData.bird1.pos);
			npcBird2.x = posToPx(gameData.bird2.pos);
			npcBird3.x = posToPx(gameData.bird3.pos);

			var ui : UIGameScene = viewComponent as UIGameScene;
			ui.qp.radar.bird1.x = gameData.bird1.percent * 206;
			ui.qp.radar.bird2.x = gameData.bird2.percent * 206;
			ui.qp.radar.bird3.x = gameData.bird3.percent * 206;
			ui.qp.radar.birdMe.x = gameData.playerBird.percent * 206;
			//
			gameSceneBg.move(deltaPlayerX);
			
			// 旗杆位置
			ui.flag.x = posToPx(GameDataModel.RACE_FINAL);
		}

		/**
		 * 跑道坐标 转换为显示坐标
		 */
		private function posToPx(pos : Number) : Number
		{
			return pos - curViewportX;
		}

		/**
		 * 题目更新
		 */
		private function onQuestionChange(e : LevelEvent) : void
		{
			var q : QuestionVO = gameData.curQuestion;
			var ui : UIGameScene = viewComponent as UIGameScene;
			ui.qp.aBtn1.visible = ui.qp.aBtn2.visible = ui.qp.aBtn3.visible = ui.qp.aBtn4.visible = true;
			ui.qp.aBtn1.mouseEnabled = ui.qp.aBtn2.mouseEnabled = ui.qp.aBtn3.mouseEnabled = ui.qp.aBtn4.mouseEnabled = true;
			ui.qp.a1Tf.text = q.allAwnsers[0];
			ui.qp.a2Tf.text = q.allAwnsers[1];
			ui.qp.a3Tf.text = q.allAwnsers[2];
			ui.qp.a4Tf.text = q.allAwnsers[3];
			ui.qp.questionTf.text = q.question;
			ui.qp.numTf.text = gameData.numQuestion.toString();
		}

		private function onAwnserClick(event : MouseEvent) : void
		{
			var ansId : int = int((event.target as DisplayObject).name.substr(4));
			var ans : String = viewComponent.qp['a' + ansId + 'Tf']['text'];
			var isCorrect : Boolean = ans == gameData.curQuestion.rightAns;
			gameData.inputAns(isCorrect);
			// gameData.getNextQuestion();
			if (isCorrect)
			{
				gameData.getNextQuestion();
				SoundMan.playSfx(SoundMan.RIGHT);
			}
			else
			{
				// 显示正确项目 1秒钟
				showRightAns(gameData.curQuestion.rightAns);
				SoundMan.playSfx(SoundMan.WRONG);
			}
		}

		private function showRightAns(rightAns : String) : void
		{
			for (var i : int = 1; i <= 4; i++)
			{
				var ans : String = viewComponent.qp['a' + i + 'Tf']['text'];
				if (rightAns == ans)
				{
					viewComponent.qp['aBtn' + i ]['mouseEnabled'] = false;
				}
				else
				{
					viewComponent.qp['a' + i + "Tf"]['text'] = "";
					viewComponent.qp['aBtn' + i ]['visible'] = false;
				}
			}
			timeoutHandle = setTimeout(next, 1000);
		}

		private function next() : void
		{
			gameData.getNextQuestion();
		}

		// 是不是重来的
		private var _isReplay : Boolean = false;

		private function onLevelStart(e : LevelEvent) : void
		{
			SoundMan.playSfx(SoundMan.GO);
			var ui : UIGameScene = viewComponent as UIGameScene;
			if (_isReplay)
			{
				// 重来的 ，不用初始化了 ，重设位置
				npcBird1.x = 0;
				npcBird2.x = 0;
				npcBird3.x = 0;
				playerBird.x = 0;
			}
			else
			{
				// 鸟初始化
				npcBird1 = new gameData.bird1.clazz();
				ui.addChild(npcBird1);
				fixBirdMC(npcBird1, 120);
				npcBird2 = new gameData.bird2.clazz();
				ui.addChild(npcBird2);
				fixBirdMC(npcBird2, 140);
				npcBird3 = new gameData.bird3.clazz();
				ui.addChild(npcBird3);
				fixBirdMC(npcBird3, 160);
				playerBird = new gameData.playerBird.clazz();
				ui.addChild(playerBird);
				// fixBirdMC(playerBird, 180);
				playerBird.scaleX = -2;
				playerBird.scaleY = 2;
				playerBird.y = 180;
				var glow : GlowFilter = new GlowFilter(0xffffff);
				// playerBird.filters = [glow];
				//
				_isReplay = true;
			}
			curViewportX = 0.0;
			ui.flag.x = GameConf.VISIBLE_SIZE_W * 2;
			gameSceneBg.reset();
			//
			gameData.getNextQuestion();
			//
			if(!CONFIG::DEBUG)
				{
					AoaoBridge.banner(contextView);
				}
		}

		private function fixBirdMC(mc : MovieClip, y : Number) : void
		{
			mc.scaleX = -1;
			mc.y = y;
		}

		private function onEnterFrame(event : Event) : void
		{
			gameData.drive();
		}
	}
}
