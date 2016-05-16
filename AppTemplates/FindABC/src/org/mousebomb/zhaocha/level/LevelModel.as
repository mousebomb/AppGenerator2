package org.mousebomb.zhaocha.level
{
	import flash.system.ApplicationDomain;
	import flash.utils.getDefinitionByName;
	import flash.display.MovieClip;
	import flash.net.SharedObject;

	import org.mousebomb.GameConf;
	import org.robotlegs.mvcs.Actor;

	/**
	 * @author Mousebomb
	 */
	public class LevelModel extends Actor
	{
		/**
		 * 总关卡数
		 */
		public var levelCount : int = 0;
		public var levelFinished : int = 0;

		public function LevelModel()
		{
		}

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
			var i :int;
			// 总关卡
			if (levelCount < 1)
			{
				levelCount = 0;
				i = 1; 
				while(true)
				{
					if( !ApplicationDomain.currentDomain.hasDefinition("Pic"+i)) break;
					levelCount = i++;
				}
				// GameConf.MAX_LEVEL;
				trace("总关卡", levelCount);
//				levelCount = 2;
			}
			// Math.floor(timuModel.questions.length / GameConf.QUESTIONS_EACHLEVEL);
			levelFinished = 0;
			for (i = 0; i < levelCount; i++)
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
				if(vo.star>0) levelFinished++;
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
