package game.model
{
	import flash.net.SharedObject;

	import org.mousebomb.GameConf;

	import game.model.vo.LevelVO;

	import org.robotlegs.mvcs.Actor;

	/**
	 * @author Mousebomb
	 */
	public class LevelModel extends Actor
	{
		/**
		 * 总关卡数
		 */
		public var levelCount : Number;

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
			levelCount = 99;
			// Math.floor(timuModel.questions.length / GameConf.QUESTIONS_EACHLEVEL);
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
				levels.push(vo);
			}
		}

		/**
		 * 记录关卡得星星
		 */
		public function saveLevel(level : int, star : int) : void
		{
            if(star<1) return;
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
