package game.model
{
	import flash.events.Event;

	/**
	 * @author Mousebomb
	 */
	public class BirdMoveEvent extends Event
	{
		/**  */
		public static const BIRDS_MOVE : String = "BIRDS_MOVE";
		
		/**  */
		public static const PLAYER_SPEED_CHANGE : String = "PLAYER_SPEED_CHANGE";
		
		public function BirdMoveEvent(type : String, bubbles : Boolean = false, cancelable : Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}
