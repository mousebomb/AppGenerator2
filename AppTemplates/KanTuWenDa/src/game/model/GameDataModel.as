package game.model
{
	import game.view.UIWelcomeMediator;
	import org.mousebomb.GameConf;
	import game.model.event.LevelEvent;
	import game.model.vo.NpcBirdVO;
	import game.model.vo.QuestionVO;
	import game.model.vo.ResultVO;

	import org.mousebomb.Math.MousebombMath;
	import org.robotlegs.mvcs.Actor;

	import flash.utils.getDefinitionByName;
	import flash.utils.getTimer;

	/**
	 * @author Mousebomb
	 */
	public class GameDataModel extends Actor
	{
		//		//  1-6
		// public var playerBird : int;
		// public var playerBirdClass : Class;
		// 1-4
		private var _curLevel : int = 0;
		//
		public var curQuestion : QuestionVO;
		//
		public var numQuestion : int = 0;
		/**
		 * 根据答题速度换算的速度 1~100
		 * 答对就增加，打错就降低，最低1
		 * 电脑控制的鸟是匀速的
		 */
		public var playerSpeedForShow : uint;
		// /**
		// * 地图上的移动速度
		// */
		// public var playerSpeed : Number;
		// 全跑道长度
		public static const RACE_START : Number = 0.0;
		public static const RACE_FINAL : Number = 5000.0;
		public static const TOTAL_DISTANCE : Number = RACE_FINAL - RACE_START;
		public var playerBird : NpcBirdVO = new NpcBirdVO();
		public var bird1 : NpcBirdVO = new NpcBirdVO();
		public var bird2 : NpcBirdVO = new NpcBirdVO();
		public var bird3 : NpcBirdVO = new NpcBirdVO();
		// 一直最快速度 40秒走完 5秒答一题
		public static var playerMaxSpeed : Number = TOTAL_DISTANCE / 40 * 2.5;
		public static var playerMinSpeed : Number = TOTAL_DISTANCE/90;
		// 开局后已经经过的时间
		public var passedTime : int = 0;
		private var _paused : Boolean = false;
		private var _lastTime : int;
		// 游戏结果
		public var resultVO : ResultVO;
		// 游戏已结束
		public var isFinished : Boolean = false;
		// 本关起始题目 整个有戏运行开始后就一直增长，一关重玩才可能恢复
		private static var _questionBeginFrom:int=0;

[Inject]
public var timuModel:TimuModel;
		public function GameDataModel()
		{
			
		}

		/**
		 * 单屏幕坐标转换为全长度
		 */
		// public function posToScene(pos:Number) : Number
		// {return pos *
		// }
		public function startLevel() : void
		{
			isFinished = false;
			_paused = false;
			passedTime = 0;
			_lastTime = getTimer();
			numQuestion = 0;
			bird1.reuse();
			bird2.reuse();
			bird3.reuse();
			for (var i : int = 1; i <= UIWelcomeMediator.birdMax; i++)
			{
				if (playerBird.birdId == i)
					continue;
				_randomBirdIds.push(i);
			}
			_randomBirdIds.sort(function(elementA : Object, elementB : Object) : Number
			{
				return Math.random() - .5;
			});
			bird1.birdId = _randomBirdIds[0];
			bird2.birdId = _randomBirdIds[1];
			bird3.birdId = _randomBirdIds[2];

			playerBird.reuse();
			playerBird.speed = 0.0;
			
			// 题库从索引开始
			timuModel.beginFrom(_questionBeginFrom);
			// 结果
			resultVO = new ResultVO();

			dispatch(new LevelEvent(LevelEvent.LEVEL_START));
		}

		public var _randomBirdIds : Array = [];

		/**
		 * 生成并返回下一题
		 */
		public function getNextQuestion() : void
		{
//			var index:int = (_questionBeginFrom + numQuestion) % timuModel.count;
//			trace('index: ' + (index));
//			curQuestion = timuModel.questions[ index ];
			curQuestion = timuModel.next();
			if(!CONFIG::DEBUG)
			curQuestion.randomize();
			++numQuestion;
			dispatch(new LevelEvent(LevelEvent.QUESTION_CHANGED));
		}

		/**
		 * 经过的毫秒
		 */
		public function drive() : void
		{
			if (paused || isFinished) return;
			var delta : int = getTimer() - _lastTime;
			_lastTime = getTimer();
			//
			passedTime += delta;
			// 求出移动距离
			bird1.update(delta);
			bird2.update(delta);
			bird3.update(delta);
			slowDown(delta);
			isFinished = playerBird.update(delta);
			dispatch(new BirdMoveEvent(BirdMoveEvent.BIRDS_MOVE));
			if (isFinished)
			{
				// 计算时间和名次 （飞行速度换算成秒）
				var playerFlyTime : Number = passedTime / 1000;
				resultVO.flyTime = [TOTAL_DISTANCE / bird1.speed, TOTAL_DISTANCE / bird2.speed, TOTAL_DISTANCE / bird3.speed];
				resultVO.birdClass = [bird1.clazz, bird2.clazz, bird3.clazz];
				resultVO.myGrade = 3;
				for (var i : int = 0; i < 3; i++)
				{
					if (resultVO.flyTime[i] > playerFlyTime)
					{
						// 插入她之前
						resultVO.myGrade = i;
						resultVO.flyTime.splice(i, 0, playerFlyTime);
						resultVO.birdClass.splice(i, 0, playerBird.clazz);
						break;
					}
				}
				if (resultVO.myGrade == 3)
				{//最后一名
					resultVO.flyTime.push(playerFlyTime);
					resultVO.birdClass.push(playerBird.clazz);
				}
				// 是否胜利
				resultVO.isWinner=resultVO.myGrade==0;
				// 计算star
				if(resultVO.isWinner)
				{
					// 赢了
					if(resultVO.correctPer>90.0)
					{
						resultVO.star = 3;
					}
					else if(resultVO.correctPer>60.0)
					{
						resultVO.star = 2;
					}else{
						resultVO.star = 1;
					}
				}
				// 计算玩家答题速度(每分钟) , 准确率(计算过程中统计的)
				resultVO.numPerMin = resultVO.totalAnswer / (playerFlyTime / 60);
				//
				dispatch(new LevelEvent(LevelEvent.PLAYER_FINISH));
			}
		}

		/**
		 * 主角会减速 最大速度减到最低速度要
		 */
		private function slowDown(delta : int) : void
		{
			playerBird.speed -= playerBird.speed * delta / 5000;
			if (playerBird.speed < GameDataModel.playerMinSpeed)
			{
				playerBird.speed = GameDataModel.playerMinSpeed;
			}
			playerSpeedForShow = playerBird.speed / playerMaxSpeed * 100;
			dispatch(new BirdMoveEvent(BirdMoveEvent.PLAYER_SPEED_CHANGE));
		}

		/**
		 * 填写答案
		 */
		public function inputAns(isCorrect : Boolean) : void
		{
			++resultVO.totalAnswer;
			if (isCorrect)
			{
//				playerBird.speed += 108;
				playerBird.speed = playerMaxSpeed;
				++resultVO.correctAnswer;
			}
			else
			{
				// 答错
				playerBird.speed -= 108;
				//
				resultVO.wrongQnA.push(curQuestion.question + "" + curQuestion.rightAns);
			}
//			if (CONFIG::DEBUG)
//				playerBird.speed = playerMaxSpeed;
			if (playerBird.speed > playerMaxSpeed)
			{
				playerBird.speed = playerMaxSpeed;
			}
			else if (playerBird.speed < playerMinSpeed)
			{
				playerBird.speed = playerMinSpeed;
			}

			playerSpeedForShow = playerBird.speed / playerMaxSpeed * 100;
			dispatch(new BirdMoveEvent(BirdMoveEvent.PLAYER_SPEED_CHANGE));
		}

		public function get paused() : Boolean
		{
			return _paused;
		}

		public function set paused(paused : Boolean) : void
		{
			this._paused = paused;
			if (_paused == false)
			{
				_lastTime = getTimer();
			}
		}

		public function get curLevel() : int
		{
			return _curLevel;
		}

		public function set curLevel(v : int) : void
		{
			this._curLevel = v;
			
			// 最快的npc鸟  60s ~ 12s 降低难度 
			var duration :Number = 60.0 - v/20;
//			trace('最快的duration: ' + (duration));
			var maxSpeed : Number = TOTAL_DISTANCE / duration;
			bird1.speed = maxSpeed;
			bird2.speed = maxSpeed * 0.75;
			bird3.speed = maxSpeed * 0.5;
			playerMinSpeed = bird3.speed;
			// 换关卡，记录换过的一关从哪里开始
			_questionBeginFrom = timuModel.index;
		}
	}
}
