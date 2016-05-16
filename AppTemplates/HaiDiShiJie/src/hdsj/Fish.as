/**
 * Created by rhett on 16/2/12.
 */
package hdsj
{

	import com.greensock.TimelineLite;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Linear;
	import com.greensock.easing.Quad;

	import flash.display.DisplayObject;

	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;
	import flash.utils.getTimer;

	import hdsj.ui.UIMain;

	import org.mousebomb.GameConf;
	import org.mousebomb.Math.MousebombMath;
	import org.mousebomb.framework.GlobalFacade;
	import org.mousebomb.interfaces.IDispose;

	/** 鱼 */
	public class Fish extends Sprite implements IDispose
	{
		private var _fishMc:MovieClip;
		private var _reverseContainer:Sprite;

		private var vo:FishVO;

		public function Fish( vo:FishVO )
		{
			super();
			this.vo = vo;
			init( vo.type, vo.id );
		}

		public function init( type:int, id:int ):void
		{
			_reverseContainer = new Sprite();
			addChild( _reverseContainer );
			var clazz:Class = getDefinitionByName( "Fish" + type + "_" + id ) as Class;
			_fishMc = new clazz();
			_reverseContainer.addChild( _fishMc );

			_curLevel = vo.calcLevel();
			_fishMc.scaleX = _fishMc.scaleY = vo.calcScale();
			speed = _reverseContainer.height / 2;
			speedForEat = speed * 1.5;

			this.x = Math.random() * GameConf.VISIBLE_SIZE_W;
			this.y = Math.random() * GameConf.VISIBLE_SIZE_H;

			//让节点循环
			var labels:Array = _fishMc.currentLabels;
			for each( var label:FrameLabel in labels )
			{
				if( label.name == "attack" )
				{
					_fishMc.addFrameScript( label.frame - 2, function ():void {_fishMc.gotoAndPlay( "move" );} );
				}
			}
			_fishMc.addFrameScript( _fishMc.totalFrames - 2, function ():void {_fishMc.stop();} );

			//
			tickTimer = new Timer( TICK_TIME );
			tickTimer.addEventListener( TimerEvent.TIMER, onTick );
			//
			moveToPos = new Point( Math.random() * GameConf.VISIBLE_SIZE_W / YuChang.curScale - GameConf.VISIBLE_SIZE_W * YuChang.curScale, Math.random() * GameConf.VISIBLE_SIZE_H_MINUS_AD );
			tickTimer.start();
		}

		public static const STATUS_STILL:uint = 58;
		public static const STATUS_MOVE:uint = 57;
		public static const STATUS_MOVING:uint = 66;

		public static const STATUS_GOTO_EAT:uint = 56;
		public static const STATUS_MOVING_EAT:uint = 67;
		/** 当前状态 */
		private var curStatus:int = STATUS_MOVE;
		/** 当前目标 */
		private var targetFood:FoodVO;

		private function onTick( event:TimerEvent ):void
		{
			//监测周围有吃的么
			// 没吃的 就随便游
			if( curStatus != STATUS_GOTO_EAT )
			{
				checkEatTarget();
			}

			switch( curStatus )
			{
				case STATUS_STILL:
					// 静止变移动
					if( getTimer() > stillEndTime )
					{
						curStatus = STATUS_MOVE;
					}
					break;
				case STATUS_GOTO_EAT:
					//食物还在么？
					if( targetFood.num <= 0 )
					{
						curStatus = STATUS_MOVE;
						targetFood = null;
					} else
					{
						//目标位置是让嘴对到
						moveToPos = targetFood.pos.clone();
						var dist:Number = MousebombMath.distanceOf2Point( new Point( x, y ), moveToPos );
						if( dist < 20 )
						{
							//吃
							fishEat();
							var eatNum:int = YuChangModel.getInstance().eatFood( targetFood, vo.calcPerEatNum() );
							vo.eat( eatNum );
							hideHungry();
							targetFood = null;
							curStatus = STATUS_MOVE;
							checkLevelUP();
						} else
						{
							move( true );
						}
					}
					break;
				case STATUS_MOVE:
					moveToPos = new Point( Math.random() * GameConf.VISIBLE_SIZE_W / YuChang.curScale + GameConf.VISIBLE_SIZE_W * (YuChang.curScale - 1) / 2, Math.random() * GameConf.VISIBLE_SIZE_H_MINUS_AD / YuChang.curScale + GameConf.VISIBLE_SIZE_H_MINUS_AD * (YuChang.curScale - 1) / 2 );
					move();
					break;
			}
			//
			outCashTick();
		}

		private function outCashTick():void
		{
			// 有钱产出了才取
			if(vo.calcOutCash()>0)
			{
					var fishCoin:FishCoin = new FishCoin();
					fishCoin.x = x;
					fishCoin.y = y;
					UIMain.flyCash( fishCoin );
					YuChangModel.getInstance().cash += vo.pickOutCash();
					GlobalFacade.sendNotify( NotifyConst.CASH_CHANGED, this );
			}
		}

		private var _curLevel:int;

		private function checkLevelUP():void
		{
			if( vo.calcLevel() > _curLevel )
			{
				//播放特效
				//刷新外形等数据
				_curLevel = vo.calcLevel();
				var sc:Number = vo.calcScale();
//				trace("Fish/checkLevelUP() type",vo.type,"等级",_curLevel,"缩放",sc);
				playLevelup(sc);
				speed = _reverseContainer.height / 2;
				speedForEat = speed * 1.5;
			}
		}

		public function playLevelup(sc:Number):void
		{
			var tl :TimelineLite = new TimelineLite();
			tl.add(	TweenMax.to(_fishMc , 0.2, {scaleX:sc*1.1 , scaleY:sc*1.3,ease:Quad.easeIn}));
			tl.add(	TweenMax.to(_fishMc , 0.2, {scaleX:sc*1.3 , scaleY:sc*1.1,ease:Quad.easeOut}));
			tl.add(	TweenMax.to(_fishMc , 0.6, {scaleX:sc , scaleY:sc,ease:Back.easeOut}));
			tl.delay(1);
			tl.play();
		}
		private function checkEatTarget():void
		{
			if( vo.isHungry() )
			{
				// 之前有食物目标么？
				if( targetFood )
				{
					//食物还在么？
					if( targetFood.num <= 0 )
					{
						curStatus = STATUS_MOVE;
						targetFood = null;
					}
				} else
				{
					showHungry();
				}
				//找吃的
				var newTargetFood:FoodVO = YuChangModel.getInstance().findFood( new Point( this.x, this.y ), vo.poolIndex );
				//找到吃的和之前不同
				if( targetFood != newTargetFood )
				{
					targetFood = newTargetFood;
					curStatus = STATUS_GOTO_EAT;
				}
			}

		}

		private function hideHungry():void
		{
			if( hungryBubble && hungryBubble.parent )
			{
				removeChild( hungryBubble );
			}
		}

		private var hungryBubble:Sprite;

		private function showHungry():void
		{
			if( hungryBubble == null )
			{
				var r:int = Math.random() * 3;
				switch( r )
				{
					case 0:
						hungryBubble = new FishHungry1();
						break;
					case 1:
						hungryBubble = new FishHungry2();
						break;
					case 2:
						hungryBubble = new FishHungry3();
						break;
				}
			}
			hungryBubble.y = -_reverseContainer.height / 2;
			addChild( hungryBubble );
		}

		public static const TICK_TIME:uint = 500;

		private var tickTimer:Timer;

		private var moveToPos:Point;
		/** 1秒游多远 */
		private var speed:Number;
		/** 觅食时候1秒游多远 */
		private var speedForEat:Number;

		public function move( forFood:Boolean = false ):void
		{
			var curPos:Point = new Point( x, y );
			//更换目的地
			var dist:Number = MousebombMath.distanceOf2Point( curPos, moveToPos );
			TweenLite.killTweensOf( this );
			curStatus = forFood ? STATUS_MOVING_EAT : STATUS_MOVING;
			var duration:Number = forFood ? (dist / speedForEat) : (dist / speed);
			var easing = forFood ? Linear.easeNone : Quad.easeOut;
			TweenLite.to( this, duration, {x:moveToPos.x, y:moveToPos.y, onComplete:onTweenComp, ease:easing} );
			if( moveToPos.x > x )
			{
				_reverseContainer.scaleX = -1;
			} else
			{
				_reverseContainer.scaleX = 1;
			}
			fishMove();
		}

		// 静止持续时间
		private var stillEndTime:int;

		private function onTweenComp():void
		{
			if( curStatus == STATUS_MOVING )
			{
				curStatus = STATUS_STILL;
				stillEndTime = getTimer() + Math.random() * 2000;
			}
			if( curStatus == STATUS_MOVING_EAT )
			{
				curStatus = STATUS_GOTO_EAT;
			}
		}

		public function fishMove():void
		{
			_fishMc.gotoAndPlay( "move" );
		}

		public function fishEat():void
		{
			_fishMc.gotoAndPlay( "attack" );
		}

		public function get depth():int
		{
			return -vo.calcLevel();
		}

		public function dispose():void
		{
			tickTimer.reset();
			tickTimer.removeEventListener( TimerEvent.TIMER, onTick );
			tickTimer = null;
			TweenLite.killTweensOf( this );

		}
	}
}
