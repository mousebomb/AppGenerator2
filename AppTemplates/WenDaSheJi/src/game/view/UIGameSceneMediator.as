package game.view {

	import com.greensock.TweenLite;
	import com.greensock.easing.Back;

	import game.AoaoGame;
	import game.model.YunShiMoveEvent;
	import game.model.DailyResultModel;
	import game.model.GameDataModel;
	import game.model.LevelModel;
	import game.model.event.LevelEvent;
	import game.model.vo.QuestionVO;

	import org.mousebomb.GameConf;
	import org.mousebomb.Math.MousebombMath;
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
		private var timeoutHandle : uint;

		public function UIGameSceneMediator()
		{
		}

		[Inject]
		public var gameData : GameDataModel;
		[Inject]
		public var dailyResultModel : DailyResultModel;
		[Inject]
		public var levelModel:LevelModel;
		
		override public function onRegister() : void
		{
			var ui : UIGameScene = viewComponent as UIGameScene;
			//
			for(var i:int = 1;i<=8;i++)
			{
				ui['yunShi'+i].mouseEnabled = false;
				ui['yunShi'+i].addEventListener(MouseEvent.CLICK, onAwnserClick);
			}
			//
			ui.qp.speed.gotoAndStop(0);
			//
			ui.pauseBtn.addEventListener(MouseEvent.CLICK, onPauseClick);

			// iPad适配
			if (GameConf.WH_RATE < GameConf.WH_RATE_IPHONE4)
			{
				var scale:Number = GameConf.VISIBLE_SIZE_W / (ui.qp.width + 40);
				ui.qp.scaleX = ui.qp.scaleY = scale;
				ui.qp.x = 26;
			}
			var scaleX : Number = GameConf.VISIBLE_SIZE_W / GameConf.DESIGN_SIZE_W;
			var centerX:Number = GameConf.VISIBLE_SIZE_W/2;
			ui.ship.x  = centerX;
			ui.question.x = centerX;
            // 完成度
            ui.qp.progBar.scaleX = 0;
			
			// BIRD radar 从10 ~ 208

			ui.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			//
			addContextListener(LevelEvent.LEVEL_START, onLevelStart);
			addContextListener(LevelEvent.QUESTION_CHANGED, onQuestionChange);
			addContextListener(LevelEvent.PLAYER_FINISH, onPlayerFinish);
			addContextListener(LevelEvent.PLAYER_EXPLODE, onPlayerExplode);
			addContextListener(YunShiMoveEvent.YUNSHI_MOVE, onYunShiMove);
			addContextListener(YunShiMoveEvent.PLAYER_SPEED_CHANGE, onPlayerSpeedChange);
			addContextListener(SceneEvent.SCENE_REQUEST_CONTINUE, onContinue);

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

		// 爆炸了
		private function onPlayerExplode(e : LevelEvent):void
		{
			var ui : UIGameScene = viewComponent as UIGameScene;
//			SoundMan.playSfx(SoundMan.);
			var date : Date = new Date();
			dailyResultModel.addToToday(date, gameData.resultVO.totalAnswer, gameData.resultVO.correctAnswer);
			levelModel.saveLevel(gameData.curLevel, gameData.resultVO.star);
			//  播放爆炸
			TweenLite.to(ui.ship,1.5,{scaleX:0.0,scaleY:0.0,ease:Back.easeIn
				,onComplete:function():void{
				dispatch(new SceneEvent(SceneEvent.SCENE_REPLACE, UIResult));
			}});
			// 锁定操作
			ui.mouseChildren=ui.mouseEnabled = false;
			//
		}

		private function onPlayerFinish(e : LevelEvent) : void
		{
			SoundMan.playSfx(SoundMan.FINISH);
			var date : Date = new Date();
			dailyResultModel.addToToday(date, gameData.resultVO.totalAnswer, gameData.resultVO.correctAnswer);
			levelModel.saveLevel(gameData.curLevel, gameData.resultVO.star);
			dispatch(new SceneEvent(SceneEvent.SCENE_REPLACE, UIResult));
		}

		private function onPlayerSpeedChange(e : YunShiMoveEvent) : void
		{
			var ui : UIGameScene = viewComponent as UIGameScene;
			// 速度变化
			ui.qp.speed.gotoAndStop(gameData.playerSpeedForShow);
		}

		/**
		 * 陨石移动更新
		 */
		private function onYunShiMove(e : YunShiMoveEvent) : void
		{
			var ui : UIGameScene = viewComponent as UIGameScene;
			for(var i:int = 1;i<=8;i++)
			{
				ui['yunShi'+i].x = gameData['yunShi'+i].pos.x + ui.ship.x;
				ui['yunShi'+i].y = gameData['yunShi'+i].pos.y + ui.ship.y;
			}
		}

		/**
		 * 题目更新
		 */
		private function onQuestionChange(e : LevelEvent) : void
		{
			var q : QuestionVO = gameData.curQuestion;
			var ui : UIGameScene = viewComponent as UIGameScene;
			for(var i:int = 1;i<=8;i++)
			{
				ui['yunShi'+i].tf.text = q.allAwnsers[i-1];
				ui['yunShi'+i].gotoAndStop(i);
				ui['yunShi'+i].mouseEnabled=ui['yunShi'+i].visible=true;
			}
			ui.question.questionTf.text = q.question;
			// 第几题
			ui.qp.timeTf.text = gameData.numQuestion.toString();
		}

		//是否在射击
		private var isShoting :Boolean = false;
		private var yunShiClicked:YunShi;

		private function onAwnserClick(event : MouseEvent) : void
		{
			if(isShoting) return;
			isShoting = true;
			//
			var ui : UIGameScene = viewComponent as UIGameScene;
			yunShiClicked = (event.currentTarget as YunShi);
			var yunShiId : int = int(yunShiClicked.name.substr(6));
			var ans : String = yunShiClicked.tf.text;
			var isCorrect : Boolean = ans == gameData.curQuestion.rightAns;
			//
			ui.ship.rotation = MousebombMath.degreesFromRadians(Math.atan2( yunShiClicked.y - ui.ship.y , yunShiClicked.x - ui.ship.x)) + 90;
			// shot
			var missile :DisplayObject = new Missile();
			missile.rotation = ui.ship.rotation;
			missile.x = ui.ship.x;
			missile.y = ui.ship.y;
			ui.addChild(missile);
			TweenLite.to(missile,.1,{ x : yunShiClicked.x ,y:yunShiClicked.y
				,onComplete:function():void{
					ui.removeChild(missile);
					gameData.inputAns(isCorrect,yunShiId);
					shotComplete(isCorrect);} });
		}

		private function shotComplete(isCorrect : Boolean):void
		{
			var ui : UIGameScene = viewComponent as UIGameScene;
			if (isCorrect)
			{
				SoundMan.playSfx(SoundMan.RIGHT);
				//爆破
				explodeYunShi(yunShiClicked);
				// 完成度
				ui.qp.progBar.scaleX = gameData.resultVO.correctAnswer / GameDataModel.numCorrectToPass;
			}
			else
			{
				SoundMan.playSfx(SoundMan.WRONG);
			}
			isShoting = false;
			yunShiClicked=null;
			next();
		}
		/**
		 * 爆破一个陨石
		 * @param yunShiClicked
		 */
		private function explodeYunShi( yunShiClicked:YunShi ):void
		{
			// 施加一个爆炸到位置
			var ui : UIGameScene = viewComponent as UIGameScene;
			var explode :Explode = new Explode();
			explode.x = yunShiClicked.x ;
			explode.y = yunShiClicked.y;
			explode.name = "explode";
			ui.addChild(explode);
			explode.addFrameScript(explode.totalFrames-1,this.explodeYunShiComplete);
		}

		private function explodeYunShiComplete():void
		{
			var ui : UIGameScene = viewComponent as UIGameScene;
			if(ui){
				var explode : MovieClip = ui.getChildByName("explode") as MovieClip;
				if(explode)
				{
					explode.stop();
					ui.removeChild(explode);
				}
			}
		}

		private function next() : void
		{
			// 继续下一题
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
			}
			else
			{
				//
				_isReplay = true;
			}
			//
			gameData.getNextQuestion();
			//
			if(!CONFIG::DEBUG)
				{
					AoaoBridge.banner(contextView);
				}
		}


		private function onEnterFrame(event : Event) : void
		{
			gameData.drive();
		}
	}
}
