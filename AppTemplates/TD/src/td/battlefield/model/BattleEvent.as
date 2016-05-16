/**
 * Created by rhett on 14/11/2.
 */
package td.battlefield.model
{

	import starling.events.Event;

	public class BattleEvent extends Event
	{

		public static const BATTLE_START:String = "BATTLE_START";
		public static const SPAWN_ENEMY:String = "SPAWN_ENEMY";
		public static const SPAWN_TOWER:String = "SPAWN_TOWER";
		public static const ENEMY_MOVES:String = "ENEMY_MOVES";
		public static const ENEMY_BEING_HIT:String = "ENEMY_BEING_HIT";
		public static const TOWER_MISSILE_LAUNCH:String = "TOWER_MISSILE_LAUNCH";

		public function BattleEvent( type:String, bubbles:Boolean = false, data:Object = null )
		{
			super( type, bubbles, data );
		}
	}
}
