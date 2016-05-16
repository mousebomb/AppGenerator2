/**
 * Created by rhett on 14/12/13.
 */
package td.battlefield.model.vo
{

	import com.shortybmc.data.parser.CSV;

	public class TowerCsvVO
	{

//		public var
		/**
		 * 塔唯一id
		 * 塔类型id * 10 + 塔等级
		 */
		public var towerId : int ;
		/**
		 * 从塔唯一id分解的塔类型
		 */
		public var type : int ;
		/**
		 * 从塔唯一id分解的塔等级
		 */
		public var level : int ;
		/**
		 * 攻击间隔
		 */
		public var attackCd : Number ;
		/**
		 * 单次攻击伤害
		 */
		public var attack : int;
		/**
		 * 建造要消耗资金
		 */
		public var money : int;
		/**
		 * 射程
		 */
		public var radius:Number;
		/**
		 * 子弹飞行速度
		 */
		public var bulletSpeed:Number;

		public static function fromCsv( towerCsv:CSV, i:int ):TowerCsvVO
		{
			var end : TowerCsvVO = new  TowerCsvVO();
			end.towerId = towerCsv.getField("towerId",i);
			end.type = end.towerId /10;
			end.level = end.towerId %10;
			end.attack = towerCsv.getField("attack",i);
			end.attackCd = towerCsv.getField("attackCd",i);
			end.money = towerCsv.getField("money",i);
			end.radius = towerCsv.getField("radius",i);
			end.bulletSpeed = towerCsv.getField("bulletSpeed",i);
			return end;
		}
	}
}
