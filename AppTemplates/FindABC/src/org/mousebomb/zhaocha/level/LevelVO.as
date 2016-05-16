package org.mousebomb.zhaocha.level
{
	/**
	 * 关卡vo
	 * @author Mousebomb
	 */
	public class LevelVO
	{
		/**
		 * 关卡号
		 */
		public var level:int = 0;
		/**
		 *  0 没过关，1～3 得分星星
		 */
		public var star : int = 0;
		/**
		 * 本关是否可玩
		 */
		public var canPlay : Boolean;
	}
}
