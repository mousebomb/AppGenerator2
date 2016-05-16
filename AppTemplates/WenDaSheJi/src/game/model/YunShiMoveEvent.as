package game.model
{
	import flash.events.Event;

	/**
	 * @author Mousebomb
	 */
	public class YunShiMoveEvent extends Event
	{
		/**  */
		public static const YUNSHI_MOVE : String = "YUNSHI_MOVE";

		/**  */
		public static const PLAYER_SPEED_CHANGE : String = "PLAYER_SPEED_CHANGE";

		public function YunShiMoveEvent(type : String, bubbles : Boolean = false, cancelable : Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}
