package org.mousebomb.wenda
{

	import org.mousebomb.framework.GlobalFacade;
	import org.mousebomb.tiezhi.*;
	import org.mousebomb.GameConf;

	import flash.display.MovieClip;
	import flash.net.SharedObject;
	/**
	 * @author Mousebomb (mousebomb@gmail.com)
	 * @date 2014年8月24日
	 */
	public class WDLevelModel extends Object
	{
		private static var _instance : WDLevelModel;

		public static function getInstance() : WDLevelModel
		{
			if (_instance == null)
			{
				_instance = new WDLevelModel(new SingletonEnforcer());
			}
			return _instance;
		}

		public function WDLevelModel(s : SingletonEnforcer)
		{
			//
			var timuService :TimuService= new TimuService();
			timuService.timuModel = timuModel=new TimuModel();
			timuService.loadTimu();
		}

/**
 * 当前关卡
 */
		public var level : int;
		/**
		 * 总关卡数
		 */
		public var levelCount : int = 0;
		/**
		 * 所有关卡
		 */
		public var wdLevels : Vector.<WDLevelVO> = new Vector.<WDLevelVO>();
		public static var timuModel:TimuModel;

		public function initAllLevels() : void
		{
			wdLevels = new Vector.<WDLevelVO>();
			var so : SharedObject = SharedObject.getLocal(GameConf.LOCAL_SO_NAME);
			if (so.data.wdLevels == null)
			{
				so.data.wdLevels = {};
			}
			levelCount = 99;
			// Math.floor(timuModel.questions.length / GameConf.QUESTIONS_EACHLEVEL);
			for (var i : int = 0; i < levelCount; i++)
			{
				var vo : WDLevelVO = new WDLevelVO();
				vo.level = i + 1;
				var savedStar : int = so.data.wdLevels[vo.level];
				vo.star = savedStar ? savedStar : 0;
				if (i == 0)
				{
					vo.canPlay = true;
				}
				else
				{
					var prevLevelStar : int = so.data.wdLevels[i];
					vo.canPlay = prevLevelStar > 0;
				}
				wdLevels.push(vo);
			}
		}

		/**
		 * 记录关卡得星星
		 */
		public function saveLevel(level : int, star : int) : void
		{
			var so : SharedObject = SharedObject.getLocal(GameConf.LOCAL_SO_NAME);
			if (so.data.wdLevels == null)
			{
				so.data.wdLevels = {};
			}
			so.data.wdLevels[level] = star;
			so.flush();
		}


	}
}

class SingletonEnforcer
{
}