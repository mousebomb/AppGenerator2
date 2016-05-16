/**
 * Created by rhett on 14/12/13.
 */
package td.util
{

	import com.shortybmc.data.parser.CSV;

	import flash.utils.Dictionary;

	import td.battlefield.model.vo.BattleCsvVO;
	import td.battlefield.model.vo.TowerCsvVO;
	import td.battlefield.model.vo.TowerCsvVO;
	import td.battlefield.model.vo.WaveCsvVO;

	/**
	 * 静态数据模型
	 *  csv转换为需要的vo
	 *
	 *  包括vo
	 *  BattleCsvVO
	 *  TowerCsvVO
	 *  WaveCsvVO
	 */
	public class StaticDataModel
	{

		private static var _instance:StaticDataModel;

		public static function getInstance():StaticDataModel
		{
			if( _instance == null )
				_instance = new StaticDataModel();
			return _instance;
		}

		public function StaticDataModel()
		{
			if( _instance != null )
				throw new Error( 'singleton' );
		}

		/**
		 * #3 加载csv
		 */
		private var csvMan :CsvManager = new CsvManager();

		public function loadCSVs(onLoaded:Function):void
		{
			csvMan.enqueue(TDGame.assetsFolder.resolvePath("csv/battle.csv").url);
			csvMan.enqueue(TDGame.assetsFolder.resolvePath("csv/tower.csv").url);
			csvMan.enqueue(TDGame.assetsFolder.resolvePath("csv/wave.csv").url);
			csvMan.loadQueue(function(ratio:Number):void{
				if(ratio ==1.0)
				{
					onLoaded();
				}
			})
		}



		/**
		 * #1 读入配置
		 */
		public function parseCsvConfigs():void
		{
			// 根据csv创建
			var rows : int;
			var i : int ;

			rows = csvMan.battleCsv.getData().length;
			battlesTotal = rows;
			for(i = 0;i<rows;i++)
			{
				var battle :BattleCsvVO = BattleCsvVO.fromCsv(csvMan.battleCsv,i);
				battleCsvDic[battle.battleId] = battle;
			}
			rows = csvMan.waveCsv.getData().length;
			for(i=0;i<rows;i++)
			{
				var wave :WaveCsvVO = WaveCsvVO.fromCsv(csvMan.waveCsv,i);
				if(null == waveCsvDic[wave.battleId])
				{
					waveCsvDic[wave.battleId] = new Vector.<WaveCsvVO> ();
				}
				waveCsvDic[wave.battleId].push(wave);
			}
			rows = csvMan.towerCsv.getData().length;
			for(i = 0;i<rows;i++)
			{
				var tower :TowerCsvVO = TowerCsvVO.fromCsv(csvMan.towerCsv,i);
				towerCsvDic[tower.towerId] = tower;
				towerCsvList.push(tower);
				if(tower.level==1)
					towerLv1CsvList.push(tower);
			}
		}
		/**
		 *
		 * #1.1 配置的battle数据
		 * [battleId] = BattleCsvVO
 		 */
		public var battleCsvDic:Dictionary = new Dictionary();
		public var battlesTotal: uint =0;

		/**
		 * # 1.2 wave
		 * 获得一个战斗里的所有波，按顺序
		 * [battleId] = Array [WaveCsvVO,...]
		 */
		public var waveCsvDic : Dictionary = new Dictionary();


		/**
		 * #1.3 Tower
		 * 获得塔配置数据
		 * [towerId]  = TowerCsvVO
		 */
		public var towerCsvDic : Dictionary = new Dictionary();
		public var towerCsvList : Vector.<TowerCsvVO> = new <TowerCsvVO>[];
		// 塔 仅第一级的
		public var towerLv1CsvList : Vector.<TowerCsvVO> = new <TowerCsvVO>[];

		public function getNextLevelTower(towerId : int):TowerCsvVO
		{
			var curTowerCsvVO:TowerCsvVO = towerCsvDic[towerId];
			var nextTowerCsvVO:TowerCsvVO = towerCsvDic[towerId+1];
			if(nextTowerCsvVO && nextTowerCsvVO.type == curTowerCsvVO.type)
			{
				return nextTowerCsvVO;
			}else{
				return null;
			}
		}
		
		/**
		 * 计算一个塔的售价
		 */
		public function getSellPrice(towerId : int ):int
		{
			var curTowerCsvVO:TowerCsvVO = towerCsvDic[towerId];
			var price : int = curTowerCsvVO.money;
			var loopTowerId : int  = towerId;
			var prevTowerCsvVO:TowerCsvVO = towerCsvDic[--loopTowerId];
			while(prevTowerCsvVO && prevTowerCsvVO.type == curTowerCsvVO.type)
			{
				price+=prevTowerCsvVO.money;
				prevTowerCsvVO = towerCsvDic[--loopTowerId];
			}
			return price/2;
		}
	}
}
