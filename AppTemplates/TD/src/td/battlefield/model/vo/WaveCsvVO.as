/**
 * Created by rhett on 14/12/13.
 */
package td.battlefield.model.vo
{

	import com.shortybmc.data.parser.CSV;

	/**
	 * 波数据
	 */
	public class WaveCsvVO
	{
		// 所属战斗
		public var battleId : int ;
		// 第几波
		public var wave : int;
		// 怪物id
		// 怪物资源图id
		public var enemyId : int ;
		// 怪物数量
		public var enemyCount : int ;
		// 多久出一个怪 秒
		public var enemySpawn : Number ;
		// 怪 hp
		public var enemyHp :int;
		// 怪移动速度 每秒像素距离
		public var moveSpeed : int ;
		// 怪物死了出的钱
		public var money : int ;

		public static function fromCsv( waveCsv:CSV, i:int ):WaveCsvVO
		{
			var end : WaveCsvVO = new WaveCsvVO();
			end.battleId = waveCsv.getField("battleId",i);
			end.wave = waveCsv.getField("wave",i);
			end.enemyId = waveCsv.getField("enemyId",i);
			end.enemyCount = waveCsv.getField("enemyCount",i);
			end.enemySpawn= waveCsv.getField("enemySpawn",i);
			end.enemyHp = waveCsv.getField("enemyHp",i);
			end.moveSpeed = waveCsv.getField("moveSpeed",i);
			end.money = waveCsv.getField("money",i);
			return end;
		}
	}
}
