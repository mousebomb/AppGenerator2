package org.mousebomb.jianbihua
{
	import org.mousebomb.GameConf;

	import flash.display.MovieClip;
	import flash.net.SharedObject;
	/**
	 * @author Mousebomb (mousebomb@gmail.com)
	 * @date 2014年8月24日
	 */
	public class JBHLevelModel extends Object
	{
		private static var _instance : JBHLevelModel;

		public static function getInstance() : JBHLevelModel
		{
			if (_instance == null)
			{
				_instance = new JBHLevelModel(new SingletonEnforcer());
			}
			return _instance;
		}

		public function JBHLevelModel(s : SingletonEnforcer)
		{
		}

/**
 * 当前关卡
 */
		public var level : int;

		public function hasNextLevel():Boolean
		{
			return level < levels.length;
		}
		/**
		 * 所有关卡
		 */
		public var levels : Vector.<int> ;

		public function initAllLevels() : void
		{
			levels = new Vector.<int>();
			for (var i : int = 0; i < GameConf.JBH_PIC_NUM; i++)
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