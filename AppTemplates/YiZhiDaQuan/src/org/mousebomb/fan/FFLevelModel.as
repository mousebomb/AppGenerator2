package org.mousebomb.fan
{

	import flash.display.MovieClip;
	import flash.net.SharedObject;

	import org.mousebomb.GameConf;

	/**
	 * @author Mousebomb (mousebomb@gmail.com)
	 * @date 2014年8月24日
	 */
	public class FFLevelModel extends Object
	{
		private static var _instance : FFLevelModel;

		public static function getInstance() : FFLevelModel
		{
			if (_instance == null)
			{
				_instance = new FFLevelModel(new SingletonEnforcer());
			}
			return _instance;
		}

		public function FFLevelModel(s : SingletonEnforcer)
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
		public var ffLevels : Vector.<FFLevelVO> = new Vector.<FFLevelVO>();

		public function initAllLevels() : void
		{
			ffLevels = new Vector.<FFLevelVO>();
			var so : SharedObject = SharedObject.getLocal(GameConf.LOCAL_SO_NAME);
			if (so.data.ffLevels == null)
			{
				so.data.ffLevels = {};
			}
			// 总关卡
			if (levelCount < 1)
			{
				var sample : MovieClip = new UIFFScenes();
				levelCount = sample.totalFrames;
				// TieZhiConf.MAX_LEVEL;
				trace("FF总关卡", levelCount);
				// levelCount = 2;
			}
			// Math.floor(timuModel.questions.length / TieZhiConf.QUESTIONS_EACHLEVEL);
			levelFinished = 0;
			for (var i : int = 0; i < levelCount; i++)
			{
				var vo : FFLevelVO = new FFLevelVO();
				vo.level = i + 1;
				var savedStar : int = so.data.ffLevels[vo.level];
				vo.star = savedStar ? savedStar : 0;
				if (i == 0)
				{
					vo.canPlay = true;
				}
				else
				{
					var prevLevelStar : int = so.data.ffLevels[i];
					vo.canPlay = prevLevelStar > 0;
				}
				if (vo.star > 0) levelFinished++;
				ffLevels.push(vo);
			}
		}

		/**
		 * 记录关卡得星星
		 */
		public function saveLevel(level : int, star : int) : void
		{
			var so : SharedObject = SharedObject.getLocal(GameConf.LOCAL_SO_NAME);
			if (so.data.ffLevels == null)
			{
				so.data.ffLevels = {};
			}
			so.data.ffLevels[level] = star;
			so.flush();
		}
	}
}

class SingletonEnforcer
{
}