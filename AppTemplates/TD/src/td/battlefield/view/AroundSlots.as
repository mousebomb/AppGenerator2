package td.battlefield.view
{
	import flash.geom.Point;
	/**
	 * @author rhett
	 */
	public class AroundSlots
	{
		// 穷举出的位置
		private static var slotPos : Vector.<Point>;
		
		/**
		 * 获得穷举出的位置 ，单位是margin，各个UI不同
		 */
		public static function getSlotPos(index : int ):Point
		{
			/*
			 * 先上／下／左右
			 * 再下一级  每一级意味着margin加一倍
			 */
			if(AroundSlots.slotPos==null)
			{
				slotPos = new Vector.<Point>( 
				);
				slotPos.push(
				//lv1
				new Point(0,-1)
				,new Point(0,1)
				,new Point(-1,0)
				,new Point(1,0)
				//lv2
				,new Point(-1,-1)
				,new Point(1,-1)
				,new Point(-1,1)
				,new Point(1,1)
				//lv3
				,new Point(0,-2)
				,new Point(0,2)
				,new Point(-2,0)
				,new Point(2,0)
				,new Point(-1,-2)
				,new Point(1,-2)
				,new Point(-1,2)
				,new Point(1,2)
				
				,new Point(2,-2)
				,new Point(2,-1)
				,new Point(2,1)
				,new Point(2,2)
				,new Point(-2,-2)
				,new Point(-2,-1)
				,new Point(-2,1)
				,new Point(-2,2)
				
				
				);
			}
			if(index >= slotPos.length)
			{
				throw new Error("无法显示此建筑点的菜单，都在屏幕外围");
			}
			return slotPos[index].clone();
		}
	}
}
