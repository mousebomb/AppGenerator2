package game.model.vo
{
	/**
	 * @author Mousebomb
	 */
	public class QuestionVO
	{
		public var allAwnsers : Array = [];
		/**
		 * 正确答案
		 */
		public var rightAns : String;

		private function randomSort(elementA : Object, elementB : Object) : int
		{
			return int(Math.random()*3)-1;
		}

		public function randomize() : void
		{
			allAwnsers.sort(randomSort);
		}
		
		/**
		 * 提问
		 */
		public var question:String ;
		
	}
}
