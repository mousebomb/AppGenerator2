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
            while(true)
            {
                allAwnsers.sort(randomSort);

                if(lastRightIndex > -1)
                {
                    var newIndex : int = allAwnsers.indexOf(rightAns);
                    if(newIndex != lastRightIndex)
                    {
                        lastRightIndex = newIndex;
                        break;
                    }
                }else{
                    lastRightIndex = allAwnsers.indexOf(rightAns);
                }
            }
		}

		/**
		 * 提问
		 */
		public var question:String ;


        // 上次正确答案的位置，为了 随机的时候，肯定不会随机到上一个位置
        private static var lastRightIndex : int =-1;
		
	}
}
