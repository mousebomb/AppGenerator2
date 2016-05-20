package org.mousebomb.pin9gong
{
	import flash.filesystem.File;

	import org.mousebomb.GameConf;

	import flash.display.MovieClip;
	import flash.net.SharedObject;

	/**
	 * @author Mousebomb (mousebomb@gmail.com)
	 * @date 2014年8月24日
	 */
	public class P9LevelModel extends Object
	{
		private static var _instance : P9LevelModel;

		public static function getInstance() : P9LevelModel
		{
			if (_instance == null)
			{
				_instance = new P9LevelModel(new SingletonEnforcer());
			}
			return _instance;
		}

		public function P9LevelModel(s : SingletonEnforcer)
		{
		}

		public static function getLevelImageFile(level_:int):File
		{
			var file:File = File.applicationDirectory.resolvePath( GameConf.P9PICSFOLDER + level_ + ".png" );
			if( !file.exists )
			{
				file = File.applicationDirectory.resolvePath( GameConf.P9PICSFOLDER + level_ + ".jpg" );
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
		public var p9Levels : Vector.<P9LevelVO> = new Vector.<P9LevelVO>();

		public function initAllLevels() : void
		{
			p9Levels = new Vector.<P9LevelVO>();
			var so : SharedObject = SharedObject.getLocal(GameConf.LOCAL_SO_NAME);
			if (so.data.p9Levels == null)
			{
				so.data.p9Levels = {};
			}
			// 总关卡
			if (levelCount < 1)
			{
				var file : File = File.applicationDirectory.resolvePath(GameConf.P9PICSFOLDER);
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
				var vo : P9LevelVO = new P9LevelVO();
				vo.level = i + 1;
				var savedStar : int = so.data.p9Levels[vo.level];
				vo.star = savedStar ? savedStar : 0;
//				if (i == 0)
//				{
					vo.canPlay = true;
//				}
//				else
//				{
//					var prevLevelStar : int = so.data.p9Levels[i];
//					vo.canPlay = prevLevelStar > 0;
//				}
				if (vo.star > 0) levelFinished++;
				p9Levels.push(vo);
			}
		}

		/**
		 * 记录关卡得星星
		 */
		public function saveLevel(level : int, star : int) : void
		{
			var so : SharedObject = SharedObject.getLocal(GameConf.LOCAL_SO_NAME);
			if (so.data.p9Levels == null)
			{
				so.data.p9Levels = {};
			}
			so.data.p9Levels[level] = star;
			so.flush();
		}
	}
}

class SingletonEnforcer
{
}