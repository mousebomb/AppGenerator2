/**
 * Created by rhett on 14/12/29.
 */
package td.battlefield.model.vo
{

	import flash.geom.Point;

	import org.mousebomb.Math.MousebombMath;
	import org.mousebomb.framework.GlobalFacade;

	import starling.animation.IAnimatable;

	import td.NotifyConst;

	public class BulletVO implements IAnimatable
	{
		// 攻击伤害
		public var attack:int;
		// 目标
		public var target :EnemyVO;
		public var x :Number;
		public var y :Number;
		public var rotation:Number;
		// 用塔的type对应子弹
		public var bulletId : int ;


		public var moveSpeed : uint = 250;

		public function advanceTime( time:Number ):void
		{
			var dist :Number = MousebombMath.distanceOf2Point(new Point(x,y),new Point(target.x,target.y));
			if(target==null)
			{
				GlobalFacade.sendNotify( NotifyConst.BULLETVO_REMOVED, this ,this);
				return;
			}
            // 有距离需要移动
			if(dist > 5.0)
			{
			//角度
			//位置
				var distanceV :Point = new Point(target.x - x , target.y-y);
				var angleV : Number = Math.atan2(distanceV.y ,distanceV.x);
				var speedV : Point = new Point( moveSpeed* Math.cos(angleV) , moveSpeed * Math.sin(angleV) );
                var dx :Number = speedV .x * time;
                var dy :Number = speedV.y * time;
				x += dx;
				y += dy;
				rotation = angleV;
                GlobalFacade.sendNotify( NotifyConst.BULLETVO_MOVED, this ,this);

                // 距离移动超过了 需要的值 （时间线溢出），也要补齐移动结束
                if( (distanceV.x >0 && dx>distanceV.x)
                    || (distanceV.x < 0 && dx<distanceV.x)
                    || (distanceV.y > 0 && dy>distanceV.y)
                    || (distanceV.y < 0 && dy<distanceV.y)
                    )
                {
                    trace("时间线溢出");
                    GlobalFacade.sendNotify( NotifyConst.BULLETVO_HITTARGET, this ,target);
                    GlobalFacade.sendNotify( NotifyConst.BULLETVO_REMOVED, this ,this);
                }
			}else{
				GlobalFacade.sendNotify( NotifyConst.BULLETVO_HITTARGET, this ,target);
				GlobalFacade.sendNotify( NotifyConst.BULLETVO_REMOVED, this ,this);
			}
		}
	}
}
