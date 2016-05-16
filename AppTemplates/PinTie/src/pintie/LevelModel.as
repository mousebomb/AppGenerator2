package pintie
{
	import flash.filesystem.File;

	import org.mousebomb.GameConf;

	import flash.display.MovieClip;
	import flash.net.SharedObject;

	/**
	 * @author Mousebomb (mousebomb@gmail.com)
	 * @date 2014年8月24日
	 */
	public class LevelModel extends Object
	{
		private static var _instance : LevelModel;
		// 每一关多少鸟
		public static const BIRDSCOUNT_INLEVEL : int = 4;
		// 每一关出现多少新鸟
		public static const NEWBIRDSCOUNT_INLEVEL : int = 4;

		public static function getInstance() : LevelModel
		{
			if (_instance == null)
			{
				_instance = new LevelModel(new SingletonEnforcer());
			}
			return _instance;
		}

		public function LevelModel(s : SingletonEnforcer)
		{
		}

		/**
		 * 当前关卡
		 */
		public var level : int;
		/**
		 * 总关卡数
		 */
		public var levelCount : int = 0;
		public var levelFinished : int = 0;
		/**
		 * 所有关卡
		 */
		public var levels : Vector.<LevelVO> = new Vector.<LevelVO>();

		public function initAllLevels() : void
		{
			levels = new Vector.<LevelVO>();
			var so : SharedObject = SharedObject.getLocal(GameConf.LOCAL_SO_NAME);
			if (so.data.levels == null)
			{
				so.data.levels = {};
			}
			// 总关卡
			if (levelCount < 1)
			{
				var file : File = File.applicationDirectory.resolvePath(GameConf.PICSFOLDER);
				var arr : Array = file.getDirectoryListing();
				for each (var picFile : File in arr)
				{
					if (picFile.extension == "png" 
					||picFile.extension == "jpg"  )
					{
						levelCount++;
					}
				}
				trace("总关卡", levelCount);
			}
			// levelCount = 2;
			// Math.floor(timuModel.questions.length / TieZhiConf.QUESTIONS_EACHLEVEL);
			levelFinished = 0;
			for (var i : int = 0; i < levelCount; i++)
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
				if (vo.star > 0) levelFinished++;
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

class SingletonEnforcer
{
}