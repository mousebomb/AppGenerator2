package game.model.vo
{
	/**
	 * @author Mousebomb
	 */
	public class ResultVO
	{
		// 是否胜利
		public var isWinner:Boolean = false;
		//我的名次 0-3
		public var myGrade :int = 0;
		// 4只鸟的飞行时间
		public var flyTime:Array = [];
		// 4只鸟的类
		public var birdClass:Array=[];
		
		// 我答题速度 1分钟几题
		public var numPerMin : Number = 0;
		// 几颗星  0为不过关 1~3
		public var star : int=0;
		// 正确率 0.0-100.0
		public function get correctPer() : Number
		{
			return correctAnswer / totalAnswer * 100;
		}
		// 本次游戏 总答题次数
		public var totalAnswer : int=0;
		// 答题正确次数
		public var correctAnswer:int=0;
		
		// 答错的题目总结
		public var wrongQnA:Vector.<String> =new Vector.<String>(); 
	}
}
