package game.model.event
{
	import flash.events.Event;

	/**
	 * @author Mousebomb
	 */
	public class LevelEvent extends Event
	{
		/**  */
		public static const LEVEL_START : String = "LEVEL_START";
		
		
		/**  */
		public static const QUESTION_CHANGED : String = "QUESTION_CHANGED";
		
		/** 玩家抵达终点 */
		public static const PLAYER_FINISH : String = "PLAYER_FINISH";
		
		public function LevelEvent(type : String, bubbles : Boolean = false, cancelable : Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}
