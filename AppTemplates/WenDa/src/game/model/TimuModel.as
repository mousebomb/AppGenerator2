package game.model
{
	import game.model.vo.QuestionVO;

	import org.robotlegs.mvcs.Actor;

	/**
	 * @author Mousebomb
	 */
	public class TimuModel extends Actor
	{
		/**
		 * 总题目数量
		 */
		public var count : int = 0;
		public var questions : Vector.<QuestionVO> = new Vector.<QuestionVO>();
		private var _index : int = 0;

		public function TimuModel()
		{
		}

		public function addTimu(question : QuestionVO) : void
		{
			questions.push(question);
			count++;
		}

		public function randomize() : void
		{
			questions.sort(randomSort);
		}

		private function randomSort(elementA : Object, elementB : Object) : int
		{
			return int(Math.random() * 3) - 1;
		}

/**
 * 拉取下一题
 */
		public function next() : QuestionVO
		{
			_index++;
//			trace('_index: ' + (_index));
			return ( questions[_index % count]);
		}

/**
 * 开始关卡的时候设置偏移
 */
		public function beginFrom(index:int) : void
		{
			_index = index;
		}

		public function get index() : int
		{
			return _index;
		}
	}
}
