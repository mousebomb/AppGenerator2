/**
 * Created by rhett on 14/11/2.
 */
package td.battlefield.model.vo
{

	import flash.geom.Point;

	import org.mousebomb.Math.MousebombMath;

	import org.mousebomb.framework.GlobalFacade;
	import org.mousebomb.framework.INotifyControler;

	import starling.animation.IAnimatable;

	import td.NotifyConst;

	public class EnemyVO implements IAnimatable
	{

		public static var nextId:uint = 1;
		public var id:uint;
		// 需行走的路径
		private var _path:Vector.<Point>;
		private var stepPointIndex : int =-1;
		private var stepPoint:Point;
		// 移动速度 每秒
		public var moveSpeed:Number;
		public var x:Number;
		public var y:Number;

		/**
		 * 外观
		 */
		public var enemyId : int;
		/**
		 * 血
		 */
		public var hp:int;
		public var maxHp:int;
		//
		public var money:int;

		public function EnemyVO()
		{
			id = nextId++;
//			trace( "EnemyVO/EnemyVO()", id );
		}


		public function advanceTime( time:Number ):void
		{
			// move
			//向量距离
//			trace("EnemyVO/advanceTime() 目的地：",stepPoint);
			var distance : Number = MousebombMath.distanceOf2Point(new Point(x,y),stepPoint);
			var movedDistance : Number = moveSpeed * time ;
			if(movedDistance>= distance)
			{
				// 走过了
				// 约等于，拐弯后的忽略
				x = stepPoint.x;
				y = stepPoint.y;
//				trace( "EnemyVO/advanceTime() "+id+" 移动到",x,y );
				GlobalFacade.sendNotify( NotifyConst.ENEMYVO_MOVED, this );
				gotoNextPoint();
			}else{
				// 没走过
				var distanceV :Point = new Point(stepPoint.x - x , stepPoint.y-y);
				var angleV : Number = Math.atan2(distanceV.y ,distanceV.x);
				var speedV : Point = new Point( moveSpeed* Math.cos(angleV) , moveSpeed * Math.sin(angleV) );
				x += speedV .x * time;
				y+= speedV.y * time;
//				trace( "EnemyVO/advanceTime() "+id+" 移动到",x,y );
				GlobalFacade.sendNotify( NotifyConst.ENEMYVO_MOVED, this );
			}
		}

		private function gotoNextPoint():void
		{
			stepPointIndex++;
			if(_path.length> stepPointIndex)
			{
				stepPoint = _path[stepPointIndex];
//				if(id==1)
//					trace("EnemyVO/gotoNextPoint() "+id,stepPointIndex,stepPoint);
			}else{
				//没有下一个了 消失
				//
				GlobalFacade.sendNotify( NotifyConst.ENEMYVO_FINISHLINE, this );
				disapear();
			}
		}

		private function disapear():void
		{
			GlobalFacade.sendNotify( NotifyConst.ENEMYVO_REMOVED, this,this );
		}

		/**
		 * 需行走的路径
		 */
		public function get path():Vector.<Point>
		{
			return _path;
		}

		/**
		 * 需行走的路径
		 * @param value
		 */
		public function set path( value:Vector.<Point> ):void
		{
			_path = value;
			stepPointIndex = 0;
			stepPoint = _path[stepPointIndex];
			x = stepPoint.x ;
			y= stepPoint.y;
		}


		/**
		 * 承受攻击
		 * @param attack
		 */
		public function onHit(attack:int):void
		{
			hp -= attack;
			if(hp <= 0 )
			{
				GlobalFacade.sendNotify( NotifyConst.ENEMYVO_ENEMYDOWN, this );
				disapear();
			}else{
				GlobalFacade.sendNotify( NotifyConst.ENEMYVO_ENEMYHIT, this );
			}
		}
	}
}
