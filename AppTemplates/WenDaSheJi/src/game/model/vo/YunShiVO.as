/**
 * Created by rhett on 15/2/20.
 */
package game.model.vo
{

	import flash.geom.Point;

	import org.mousebomb.GameConf;

	import org.mousebomb.Math.MousebombMath;

	public class YunShiVO
	{
		/**
		 *
		 * @param position_ 位置 [1-8]
		 */
		public function YunShiVO( position_:uint )
		{
			switch( position_ )
			{
				case 1:
					_angle = MousebombMath.radiansFromDegrees(90);
					break;
				case 2:
					_angle = MousebombMath.radiansFromDegrees(55);
					break;
				case 3 :
					_angle = MousebombMath.radiansFromDegrees(0);
					break;
				case 4 :
					_angle = MousebombMath.radiansFromDegrees(305);
					break;
				case 5 :
					_angle = MousebombMath.radiansFromDegrees(270);
					break;
				case 6 :
					_angle = MousebombMath.radiansFromDegrees(235);
					break;
				case 7 :
					_angle = MousebombMath.radiansFromDegrees(180);
					break;
				case 8 :
					_angle = MousebombMath.radiansFromDegrees(125);
					break;
			}
			reset();
		}

		public function reset():void
		{
			_percent = 2.0;
			_flyInMS = 0;
			_movedMS = 0;
			calcPos();
		}

		private function calcPos():void
		{
			// 横向拉长
			_pos.x = int(_percent * Math.cos( _angle )   * GameConf.VISIBLE_SIZE_W * .42);
			_pos.y = int(-_percent * Math.sin( _angle ) * (GameConf.VISIBLE_SIZE_H-80) * .35);
		}

		// 对应主角的角度
		private var _angle:Number;

		// 撞击距离 百分比 0.0为撞击 [0.0,1.0]
		private var _percent:Number;
		// 坐标
		private var _pos:Point = new Point();

		// 移动速度 走完100%需要N毫秒
		public static var moveTimeMS : uint = GameConf.YUNSHI_MOVE_TIME;
		// 已移动毫秒
		private var _movedMS : uint = 0;
		private var _flyInMS:uint =0;

		/**
		 * 更新位置
		 * @param delta 经过时间
		 * @return 是否碰撞
		 */
		public function update( delta:uint ):Boolean
		{
			if(_percent>1.0)
			{
				// 高速飞入
				_flyInMS+=delta;
				_percent = 2.0-(_flyInMS/500);
				if(_percent < 1.0) _percent = 1.0;
			}else{
				_movedMS += delta;
				_percent = 0.6 + 0.4 - (_movedMS / moveTimeMS) * .4;
				if(_percent <.6)
				{
					_percent = .6;
					calcPos();
					return true;
				}
			}
			calcPos();
			return false;
		}

		public function get pos():Point {return _pos;}
	}
}
