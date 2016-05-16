package game.model
{

	import game.model.vo.YunShiVO;
	import game.view.UIWelcomeMediator;
	import org.mousebomb.GameConf;
	import game.model.event.LevelEvent;
	import game.model.vo.QuestionVO;
	import game.model.vo.ResultVO;

	import org.mousebomb.Math.MousebombMath;
	import org.robotlegs.mvcs.Actor;
import org.mousebomb.GameConf;

	import flash.utils.getDefinitionByName;
	import flash.utils.getTimer;

	/**
	 * @author Mousebomb
	 */
	public class GameDataModel extends Actor
	{
		// 1-4
		private var _curLevel : int = 0;
		//
		public var curQuestion : QuestionVO;
		//
		public var numQuestion : int = 0;
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

		// 回答对几题算过关
		public static var numCorrectToPass:int = GameConf.NUM_CORRECT2PASS;

		// 陨石
		public var yunShi1:YunShiVO = new YunShiVO(1);
		public var yunShi2:YunShiVO = new YunShiVO(2);
		public var yunShi3:YunShiVO = new YunShiVO(3);
		public var yunShi4:YunShiVO = new YunShiVO(4);
		public var yunShi5:YunShiVO = new YunShiVO(5);
		public var yunShi6:YunShiVO = new YunShiVO(6);
		public var yunShi7:YunShiVO = new YunShiVO(7);
		public var yunShi8:YunShiVO = new YunShiVO(8);

		[Inject]
		public var timuModel:TimuModel;
		// 玩家速度 （显示 1-100）
		public var playerSpeedForShow:int = 1;
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
			//
			for(var i:int = 1;i<=8;i++)
			{
				this['yunShi' + i].reset();
			}
			
			// 题库从索引开始
			timuModel.beginFrom(_questionBeginFrom);
			// 结果
			resultVO = new ResultVO();

			dispatch(new LevelEvent(LevelEvent.LEVEL_START));
		}

		/**
		 * 生成并返回下一题
		 */
		public function getNextQuestion() : void
		{
//			var index:int = (_questionBeginFrom + numQuestion) % timuModel.count;
//			trace('index: ' + (index));
//			curQuestion = timuModel.questions[ index ];
			curQuestion = timuModel.next();
//			if(!CONFIG::DEBUG)
			curQuestion.randomize();
			++numQuestion;
			dispatch(new LevelEvent(LevelEvent.QUESTION_CHANGED));
		}

		/**
		 * 是否测试足够过关了
		 * @return
		 */
		public function isTestEnough():Boolean
		{
			return resultVO.correctAnswer >= numCorrectToPass;
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
			// 求出移动距离    YunShi  判定游戏失败
			var isHitYunShi:Boolean  =
					yunShi1.update(delta) ||
					yunShi2.update(delta) ||
					yunShi3.update(delta)||
					yunShi4.update(delta)||
					yunShi5.update(delta)||
					yunShi6.update(delta)||
					yunShi7.update(delta)||
					yunShi8.update(delta);
			//判定游戏结束
			isFinished = isHitYunShi  || isTestEnough();
			dispatch(new YunShiMoveEvent(YunShiMoveEvent.YUNSHI_MOVE));
			if (isFinished)
			{
				// 计算时间
				resultVO.flyTimeMS = passedTime;
				// 是否胜利
				resultVO.isWinner= !isHitYunShi;
				// 计算玩家答题速度(每分钟) , 准确率(计算过程中统计的)
				resultVO.numPerMin = resultVO.totalAnswer / (passedTime / 1000 / 60);
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
					//
					dispatch(new LevelEvent(LevelEvent.PLAYER_FINISH));
				}else{
					// 输了
					dispatch(new LevelEvent(LevelEvent.PLAYER_EXPLODE));
				}
			}
		}

		/**
		 * 填写答案
		 */
		public function inputAns(isCorrect : Boolean,yunShiId:int) : void
		{
			++resultVO.totalAnswer;
			if (isCorrect)
			{
				++resultVO.correctAnswer;
				// 陨石爆炸 替补陨石
				(this['yunShi' + yunShiId] as YunShiVO).reset();
			}
			else
			{
				// 答错
				//
				resultVO.wrongQnA.push(curQuestion.question + "" + curQuestion.rightAns);
			}
			playerSpeedForShow = int(resultVO.correctPer);
			dispatch( new YunShiMoveEvent(YunShiMoveEvent.PLAYER_SPEED_CHANGE));
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
			// 换关卡，记录换过的一关从哪里开始
			_questionBeginFrom = timuModel.index;
		}
	}
}
