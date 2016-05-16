package game.view
{
	import flash.events.Event;

	/**
	 * @author Mousebomb
	 */
	public class SceneEvent extends Event
	{
		/**  */
		public static const SCENE_REPLACE : String = "SCENE_REPLACE";
		
		/**  */
		public static const SCENE_REQUEST_PAUSE : String = "SCENE_REQUEST_PAUSE";
		public static const SCENE_REQUEST_CONTINUE : String = "SCENE_REQUEST_CONTINUE";
		/** 用户请求重玩 */
		public static const SCENE_REQUEST_REPLAY : String = "SCENE_REQUEST_REPLAY";
		
		public var presentView:Class;

		public function SceneEvent(type : String, presentView:Class)
		{
			super(type);
			this.presentView = presentView;
		}
	}
}
