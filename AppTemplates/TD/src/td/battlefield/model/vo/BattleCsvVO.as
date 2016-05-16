package td.battlefield.model.vo
{

	import com.shortybmc.data.parser.CSV;

	import flash.geom.Point;

	/**
	 * 战斗配置数据
	 */
	public class BattleCsvVO
	{
		/**
		 * 战斗ID 对应level 从1开始
		 */
		public var battleId : int;
		/**
		 * 初始资金
		 */
		public var initMoney : int;
		/**
		 * 怪物路径
		 */
		public var path:Vector.<Point>;
		/**
		 * 塔建造位置
		 */
		public var towerslot : Vector.<Point>;
		/**
		 * 血显示的位置
		 */
		public var lifePos : Point;


		public static function fromCsv( csv:CSV, index:int ):BattleCsvVO
		{
			var battle : BattleCsvVO = new BattleCsvVO();

			battle.battleId = csv.getField("battleId",index);
			battle.path = csv.parsePoints(csv.getField("path",index));
			battle.towerslot = csv.parsePoints(csv.getField("towerslot",index));
			battle.initMoney = csv.getField("initMoney",index);
			battle.lifePos = csv.parsePoints(csv.getField("lifepos",index))[0];
			return battle;
		}

	}
}
