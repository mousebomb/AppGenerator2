package org.mousebomb.tiezhi
{
	import org.mousebomb.GameConf;

	import flash.display.MovieClip;
	import flash.net.SharedObject;
	/**
	 * @author Mousebomb (mousebomb@gmail.com)
	 * @date 2014年8月24日
	 */
	public class TZLevelModel extends Object
	{
		private static var _instance : TZLevelModel;
		// 每一关多少鸟
		public static const BIRDSCOUNT_INLEVEL : int= 4;
		// 每一关出现多少新鸟
		public static const NEWBIRDSCOUNT_INLEVEL : int= 4;

		public static function getInstance() : TZLevelModel
		{
			if (_instance == null)
			{
				_instance = new TZLevelModel(new SingletonEnforcer());
			}
			return _instance;
		}

		public function TZLevelModel(s : SingletonEnforcer)
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
		public var tzLevels : Vector.<TZLevelVO> = new Vector.<TZLevelVO>();

		public function initAllLevels() : void
		{
			tzLevels = new Vector.<TZLevelVO>();
			var so : SharedObject = SharedObject.getLocal(GameConf.LOCAL_SO_NAME);
			if (so.data.tzLevels == null)
			{
				so.data.tzLevels = {};
			}
			// 总关卡
			if (levelCount < 1)
			{
				// 贴纸总关卡 自动用PicN获取
				var sample : MovieClip = new UITZScenes();
				levelCount = sample.totalFrames;
				// GameConf.MAX_LEVEL;
				trace("总关卡", levelCount);
				// levelCount = 2;
			}
			// Math.floor(timuModel.questions.length / GameConf.QUESTIONS_EACHLEVEL);
			levelFinished = 0;
			for (var i : int = 0; i < levelCount; i++)
			{
				var vo : TZLevelVO = new TZLevelVO();
				vo.level = i + 1;
				var savedStar : int = so.data.tzLevels[vo.level];
				vo.star = savedStar ? savedStar : 0;
				if (i == 0)
				{
					vo.canPlay = true;
				}
				else
				{
					var prevLevelStar : int = so.data.tzLevels[i];
					vo.canPlay = prevLevelStar > 0;
				}
				if (vo.star > 0) levelFinished++;
				tzLevels.push(vo);
			}
		}

		/**
		 * 记录关卡得星星
		 */
		public function saveLevel(level : int, star : int) : void
		{
			var so : SharedObject = SharedObject.getLocal(GameConf.LOCAL_SO_NAME);
			if (so.data.tzLevels == null)
			{
				so.data.tzLevels = {};
			}
			so.data.tzLevels[level] = star;
			so.flush();
		}
	}
}

class SingletonEnforcer
{
}