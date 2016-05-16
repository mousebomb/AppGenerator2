/**
 * Created by rhett on 14/11/2.
 */
package td.battlefield.model.vo
{

	import flash.geom.Point;

	import org.mousebomb.framework.GlobalFacade;

	import starling.animation.IAnimatable;

	import td.NotifyConst;

	import td.battlefield.model.BattleFieldModel;

	import td.battlefield.model.BattleFieldModel;
	import td.battlefield.model.vo.EnemyVO;

	public class TowerVO implements IAnimatable
	{
		public static var nextId:uint = 1;
		public var id:uint;

		public var towerId : int ;
		public var type : int ;

		// 塔 位置
		public var x:Number;
		public var y:Number;
		// 射程
		public var radius : Number;
		public var attack : int;

		public var attackCd : Number ;
		//
		public var bulletSpeed : Number ;

		public function TowerVO( towerSlot_:Point )
		{
			id = nextId++;
			x = towerSlot_.x;
			y = towerSlot_.y;
			towerId = 0;
		}

		private var cdTime :Number=0.0;
		private var _state : uint  =STATE_STOP;
		public static const STATE_ATK:uint = 41;
		public static const STATE_STOP:uint = 43;

		public function advanceTime( time:Number ):void
		{
			if(towerId ==0) return;
			cdTime += time;
			// cd后攻击
			if(cdTime>=attackCd)
			{
				cdTime = cdTime %attackCd;
				var enemy :EnemyVO = BattleFieldModel.getInstance().nearestEnemy(x,y,radius);
				if(!enemy ) return ;
				BattleFieldModel.getInstance().launchBullet(this,enemy);
				state = STATE_ATK;
			}else{
				state = STATE_STOP;
			}
		}

		public function get state():uint
		{
			return _state;
		}

		public function set state( value:uint ):void
		{
			if(_state == value) return;
			_state = value;
			GlobalFacade.sendNotify( NotifyConst.TOWERVO_STATE_CHANGED, this,_state );
		}
	}
}
