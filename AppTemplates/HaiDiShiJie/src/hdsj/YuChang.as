/**
 * Created by rhett on 16/2/12.
 */
package hdsj
{

	import com.greensock.TweenLite;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.GesturePhase;
	import flash.events.MouseEvent;
	import flash.events.TransformGestureEvent;
	import flash.geom.Point;
	import flash.system.Capabilities;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;

	import hdsj.ui.UIMain;

	import org.mousebomb.GameConf;
	import org.mousebomb.Math.MousebombMath;
	import org.mousebomb.framework.GlobalFacade;
	import org.mousebomb.framework.Notify;
	import org.mousebomb.interfaces.IDispose;

	/**
	 * 渔场
	 */
	public class YuChang extends Sprite
	{
		private var bgLayer:Sprite;
		private var fishLayer:Sprite;

		public function YuChang()
		{
			super();
			bgLayer = new Sprite();
			bgLayer.addChild( YuChangBG.getInstance() );
			addChild( bgLayer );

			fishLayer = new Sprite();
			addChild( fishLayer );
			addFishes();
			addFoods();

			//
			this.addEventListener( MouseEvent.RELEASE_OUTSIDE, onMouseUp );
			this.addEventListener( MouseEvent.MOUSE_UP, onMouseUp );
			this.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );

			Multitouch.inputMode = MultitouchInputMode.GESTURE;
			this.addEventListener( Event.ADDED_TO_STAGE, onStage );
			//
			GlobalFacade.regListener( NotifyConst.PUT_FOOD, onNPutFood );
			GlobalFacade.regListener( NotifyConst.FISH_ADDED_CURPOOL, onNFishAdded );
			GlobalFacade.regListener( NotifyConst.POOL_CHANGED, onNPoolChanged );
			//
//
		}


		private function onNPoolChanged( n:Notify ):void
		{
			//刷新场景数据
			removeFishesOrFoods();
			addFishes();
			addFoods();
			// 显示钱
		}

		private function onNFishAdded( n:Notify ):void
		{
			var fishVO:FishVO = n.data as FishVO;
			addFish( new Fish( fishVO ) );
		}

		private function onStage( event:Event ):void
		{
			this.removeEventListener( Event.ADDED_TO_STAGE, onStage );
			stage.addEventListener( TransformGestureEvent.GESTURE_ZOOM, onGestureZoom, true );

		}

		public static var minScale:Number = 0.2;
		public static var maxScale:Number = 1.0;
		private var isZooming:Boolean = false;
		public static var curScale:Number = 1.0;
		/** 当前缩放比例下的0点偏移 */
		private var orX:Number=0;
		private var orY:Number=0;

		private function onGestureZoom( event:TransformGestureEvent ):void
		{
			if( UIMain.hasPopupUI() ) return;
			if( event.phase == GesturePhase.BEGIN )
			{
				//取消此前的mouseDOwn
				this.removeEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
				isMouseMovedAndCanceled=true;
				isMouseMoved=false;
//				trace("YuChang/onGestureZoom() BEGIN");
				isZooming = true;
			}
			if( event.phase == GesturePhase.UPDATE )
			{
//				trace("YuChang/onGestureZoom() UPDATE");
				// 缩放
				curScale = event.scaleX * fishLayer.scaleX;
				if( curScale < minScale ) curScale = minScale;
				if( curScale > maxScale ) curScale = maxScale;
				fishLayer.scaleX = fishLayer.scaleY = curScale;
				orX=fishLayer.x = GameConf.VISIBLE_SIZE_W * (1 - curScale) / 2;
				orY=fishLayer.y = GameConf.VISIBLE_SIZE_H_MINUS_AD * (1 - curScale) / 2;
				//
			}
			if( event.phase == GesturePhase.END )
			{
//				trace("YuChang/onGestureZoom() END");
				isZooming = false;
				event.stopPropagation();
			}
		}

		private function onNPutFood( n:Notify ):void
		{
			var foodVO:FoodVO = n.data;
			addFood( foodVO );
		}

		private function addFood( foodVO:FoodVO ):void
		{
			fishLayer.addChild( new Food( foodVO ) );
		}

		private var isMouseMoved:Boolean = false;
		private var isMouseMovedAndCanceled:Boolean = false;
		private var mouseDownPoint:Point;

		private function onMouseMove( event:MouseEvent ):void
		{
			if(isZooming) return;
//			trace("YuChang/onMouseMove()");
			var oldMoved:Boolean = isMouseMoved;
			isMouseMoved = ( MousebombMath.distanceOf2Point( new Point( event.stageX, event.stageY ), mouseDownPoint ) > Capabilities.screenDPI / 18);
			if( isMouseMoved )
			{
				if( Math.abs( event.stageX - mouseDownPoint.x ) > Math.abs( event.stageY - mouseDownPoint.y ))
				{
					fishLayer.x = orX+ (event.stageX - mouseDownPoint.x) / 2;
				}else{
					fishLayer.y = orY+ (event.stageY - mouseDownPoint.y) / 2;
				}
			}else{
				fishLayer.x= orX;
				fishLayer.y = orY;
			}
			if(oldMoved==true && isMouseMoved==false)
			{
				isMouseMovedAndCanceled =true;
			}
		}

		private function onMouseDown( event:MouseEvent ):void
		{
			if(isZooming) return;
//			trace("YuChang/onMouseDown()");
			if( UIMain.hasPopupUI() ) return;
			TweenLite.killTweensOf(fishLayer);
			fishLayer.x =orX;
			fishLayer.y =orY;
			mouseDownPoint = new Point( event.stageX, event.stageY );
			this.addEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );

		}

		private function onMouseUp( event:MouseEvent ):void
		{
			if(isZooming) return;
//			trace("YuChang/onMouseUp()");
			if( UIMain.hasPopupUI() )
			{
				GlobalFacade.sendNotify( NotifyConst.CLOSE_POPUP_UI, this );
				return;
			}
			TweenLite.killTweensOf(fishLayer);
			fishLayer.x = orX;
			fishLayer.y = orY;
			this.removeEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
			var mouseUpPoint:Point = new Point( event.stageX, event.stageY );

			var ycModel:YuChangModel = YuChangModel.getInstance();
			if( isMouseMoved )
			{
				// 换场景
				if( Math.abs( event.stageX - mouseDownPoint.x ) > Math.abs( event.stageY - mouseDownPoint.y ) )
				{
					if( event.stageX > mouseDownPoint.x )
					{
						//按下右移了
						if(ycModel.gotoPool( ycModel.curPoolX - 1, ycModel.curPoolY ))
							TweenLite.from(fishLayer,0.4,{x:-300});
					} else
					{
						if(ycModel.gotoPool( ycModel.curPoolX + 1, ycModel.curPoolY ))
							TweenLite.from(fishLayer,0.4,{x:300});
					}
				} else
				{
					if( event.stageY > mouseDownPoint.y )
					{
						if(ycModel.gotoPool( ycModel.curPoolX, ycModel.curPoolY - 1 ))
							TweenLite.from(fishLayer,0.4,{y:-300});
					} else
					{
						if(ycModel.gotoPool( ycModel.curPoolX, ycModel.curPoolY + 1 ))
							TweenLite.from(fishLayer,0.4,{y:300});
					}
				}
			} else if(!isMouseMovedAndCanceled)
			{
				// 放食物
				var localPoint:Point = fishLayer.globalToLocal( mouseUpPoint );
				ycModel.giveFood( localPoint );
			}
			isMouseMoved = false;
			isMouseMovedAndCanceled=false;
		}


		private function addFoods():void
		{
			var model:YuChangModel = YuChangModel.getInstance();
			var foods:Array = model.getFoodInCurPool();
			for each ( var vo:FoodVO in foods )
			{
				addFood( vo );
			}
		}

		private function addFishes():void
		{
			var model:YuChangModel = YuChangModel.getInstance();
			var fishes:Array = model.getFishInCurPool();
			for each( var vo:FishVO in fishes )
			{
				addFish( new Fish( vo ) );
			}
			sort();
		}

		private function removeFishesOrFoods():void
		{
			fishList = [];
			for (var i:int = fishLayer.numChildren-1;i>=0;--i)
			{
				var fishOrFood:IDispose = fishLayer.getChildAt(i) as IDispose;
				fishOrFood.dispose();
				fishLayer.removeChildAt(i);
			}
		}

		private function addFish( fish:Fish ):void
		{
			fishList.push( fish );
			fishLayer.addChild( fish );
		}

		public var fishList:Array = [];

		private function sort():void
		{

			fishList.sort( sortDepth );
			setRenderIndex( fishList );
		}

		private function setRenderIndex( sourceArr:Array ):void
		{
			if( !sourceArr ) return;
			var curIndex:int=0;
			for( var i:int = 0; i < sourceArr.length; i++ )
			{
				if( sourceArr[i] is Fish )
				{
					var a:DisplayObject = sourceArr[i];
					if( fishLayer.getChildIndex( a ) != curIndex )
					{
						fishLayer.setChildIndex( a, curIndex++ );
					} else
					{
						curIndex++;
					}
				}
			}
		}

		private function sortDepth( a:Fish, b:Fish ):int
		{
			//return a.depth - b.depth;
			if( a.depth > b.depth )
			{
				return 1;
			} else if( a.depth < b.depth )
			{
				return -1;
			}
			return 1;
		}


	}
}
