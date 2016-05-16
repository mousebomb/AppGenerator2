package fan
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

		public static function getInstance() : LevelModel
		{
			if (_instance == null)
			{
				_instance = new LevelModel(new SingletonEnforcer());
				_instance.initPicNum();
			}
			return _instance;
		}

		public function LevelModel(s : SingletonEnforcer)
		{
		}

		public static var PIC_NUM : int =0;
		public function initPicNum():void
		{
			// 总关卡
			if (PIC_NUM < 1)
			{
				var file : File = File.applicationDirectory.resolvePath("pics/");
				var arr : Array = file.getDirectoryListing();
				for each (var picFile : File in arr)
				{
					if (picFile.extension == "png"
							||picFile.extension == "jpg"  )
					{
						PIC_NUM++;
					}
				}
				trace("PIC_NUM", PIC_NUM);
			}
		}

		public static function getImageFile(pic_:int):File
		{
			var file:File = File.applicationDirectory.resolvePath( "pics/" + pic_ + ".png" );
			if( !file.exists )
			{
				file = File.applicationDirectory.resolvePath( "pics/" + pic_ + ".jpg" );
			}
			return file;
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
				var sample : MovieClip = new Scenes();
				levelCount = sample.totalFrames;
				// TieZhiConf.MAX_LEVEL;
				trace("总关卡", levelCount);
				// levelCount = 2;
			}
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

		/** 获得某关卡的配置 */
		public function getLevelConf(level : int ) : Array
		{
			var index : int = (level-1);
			var levelsArr :Array = GameConf.levelShelf.split(";");
			if(levelsArr.length <= index)
			{
				return levelsArr[levelsArr.length-1].split(",");
			}else {
				return levelsArr[index].split(",");
			}
		}
	}
}

class SingletonEnforcer
{
}