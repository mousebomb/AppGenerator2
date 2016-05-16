/**
 * Created by rhett on 16/2/13.
 */
package hdsj
{

	public class YuChangVO
	{

		public var unlockedPoolCount : int ;
		public var pools :Array ;
		public function YuChangVO()
		{
		}

		public function load():void
		{
			pools = [];
		}
	}
}
