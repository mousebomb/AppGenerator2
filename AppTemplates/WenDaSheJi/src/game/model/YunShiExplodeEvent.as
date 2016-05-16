package game.model
{
	import flash.events.Event;

	/**
	 * @author Mousebomb
	 */
	public class YunShiExplodeEvent extends Event
	{
		/** */
		public static const YUNSHI_EXPLODE : String = "YUNSHI_EXPLODE";
		private var yunShiId:int;

		public function YunShiExplodeEvent(type : String, yunShiId:int)
		{
			super(type);
			this.yunShiId = yunShiId;

		}
	}
}
