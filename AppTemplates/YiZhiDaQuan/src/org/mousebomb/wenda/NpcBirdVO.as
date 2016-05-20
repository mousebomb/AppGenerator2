/**
 * Created by rhett on 16/5/18.
 */
package org.mousebomb.wenda
{

	import flash.utils.getDefinitionByName;

	public class NpcBirdVO
	{
		public function NpcBirdVO()
		{
		}
		/**
		 * 场景移动速度
		 * (像素 / 秒)
		 */
		public var speed : Number = 0.0;
		/**
		 * 衰减的速度 (px / sec)
		 */
		public var speedSlowDown : Number = 0.0;
		/**
		 * 比赛 位置
		 */
		public var pos : Number;
		/**
		 * 鸟的类
		 */
		public var clazz : Class;
		private var _birdId : int;
		public var finished : Boolean = false;

		public function get percent() : Number
		{
			return (pos-WDDatiModel.RACE_START) / (WDDatiModel.TOTAL_DISTANCE);
		}

		/**
		 * 匀速移动
		 */
		public function update(delta : int) : Boolean
		{
			if (finished) return true;
			pos += speed * delta / 1000;
			if (pos >= WDDatiModel.RACE_FINAL)
			{
				finished = true;
				return true;
			}
			return false;
		}

		public function reuse() : void
		{
			finished = false;
			pos = WDDatiModel.RACE_START;
		}

		public function get birdId() : int
		{
			return _birdId;
		}

		public function set birdId(birdId : int) : void
		{
			this._birdId = birdId;
			clazz = getDefinitionByName("Bird" + birdId) as Class;
		}
	}
}
