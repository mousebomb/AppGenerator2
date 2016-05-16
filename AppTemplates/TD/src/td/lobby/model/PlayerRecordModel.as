/**
 * Created by rhett on 15/1/1.
 */
package td.lobby.model
{

	import flash.net.SharedObject;

	import org.mousebomb.GameConf;

	import td.lobby.model.vo.LevelVO;

	import td.util.StaticDataModel;

	import td.util.StaticDataModel;

	public class PlayerRecordModel
	{
		private static var _instance:PlayerRecordModel;

		public static function getInstance():PlayerRecordModel
		{
			if( _instance == null )
				_instance = new PlayerRecordModel();
			return _instance;
		}

		public function PlayerRecordModel()
		{
			if( _instance != null )
				throw new Error( 'singleton' );
		}



		/**
		 * 所有关卡
		 */
		public var levels : Vector.<LevelVO> = new Vector.<LevelVO>();

		public function initAllLevels() : void
		{
			//
			var staticData :StaticDataModel = StaticDataModel.getInstance();
			//
			levels = new Vector.<LevelVO>();
			var so : SharedObject = SharedObject.getLocal(GameConf.LOCAL_SO_NAME);
			if (so.data.levels == null)
			{
				so.data.levels = {};
			}
			// Math.floor(timuModel.questions.length / GameConf.QUESTIONS_EACHLEVEL);
			for (var i : int = 0; i < staticData.battlesTotal; i++)
			{
				var vo : LevelVO = new LevelVO();
				vo.level = i + 1;
				var savedStar : int = so.data.levels[vo.level];
				vo.star = savedStar ? savedStar : 0;
				if (i == 0)
				{
					vo.canPlay = true;
				}
				else
				{
					var prevLevelStar : int = so.data.levels[i];
					vo.canPlay = prevLevelStar > 0;
				}
				levels.push(vo);
			}
		}

		/**
		 * 记录关卡得星星
		 */
		public function saveLevel(level : int, star : int) : void
		{
			var so : SharedObject = SharedObject.getLocal(GameConf.LOCAL_SO_NAME);
			if (so.data.levels == null)
			{
				so.data.levels = {};
			}
			so.data.levels[level] = star;
			so.flush();
		}
	}
}
