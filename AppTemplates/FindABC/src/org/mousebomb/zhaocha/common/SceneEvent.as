package org.mousebomb.zhaocha.common
{
	import flash.events.Event;

	/**
	 * @author Mousebomb
	 */
	public class SceneEvent extends Event
	{
		/**  */
		public static const SCENE_REPLACE : String = "SCENE_REPLACE";
		
		public var presentView:Class;

		public function SceneEvent(type : String, presentView:Class)
		{
			super(type);
			this.presentView = presentView;
		}
	}
}
