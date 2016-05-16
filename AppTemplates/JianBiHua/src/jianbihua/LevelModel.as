package jianbihua
{
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
		 * 所有关卡
		 */
		public var levels : Vector.<int> ;

		public function initAllLevels() : void
		{
			levels = new Vector.<int>();
			for (var i : int = 0; i < GameConf.PIC_NUM; i++)
			{
				var vo : int = i + 1;
				levels.push(vo);
			}
		}

	}
}

class SingletonEnforcer
{
}