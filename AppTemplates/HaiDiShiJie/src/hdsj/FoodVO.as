/**
 * Created by rhett on 16/2/13.
 */
package hdsj
{

	import flash.geom.Point;

	public class FoodVO
	{
		/** 所剩分量 */
		public var num:int;

		/** 所在位置 */
		public var pos:Point;

		/** 一开始的分量 */
		public var numTotal:int;

		/** 剩余比例 */
		public function get leftPercent():Number
		{
			return num/numTotal;
		}

		public function FoodVO()
		{
		}

	}
}
