/**
 * Created by rhett on 16/2/14.
 */
package hdsj
{

	import com.greensock.TweenLite;

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;

	import org.mousebomb.framework.GlobalFacade;
	import org.mousebomb.framework.Notify;
	import org.mousebomb.interfaces.IDispose;

	public class Food extends Sprite implements IDispose
	{
		private var _foodMc:MovieClip;
		private var _vo:FoodVO;

		public function Food( foodVO:FoodVO )
		{
			super();
			_vo = foodVO;
			var r:int = Math.random() * 3;
			switch( r )
			{
				case 0:
					_foodMc = new FishFood1();
					break;
				case 1:
					_foodMc = new FishFood2();
					break;
				case 2:
					_foodMc = new FishFood3();
					break;
			}
			var p:Number = foodVO.leftPercent;
			if( p > 2 / 3 ) _foodMc.gotoAndStop( 1 ); else if( p > 1 / 3 ) _foodMc.gotoAndStop( 2 ); else _foodMc.gotoAndStop( 3 );
			addChild( _foodMc );
			this.x = foodVO.pos.x;
			this.y = foodVO.pos.y;
			GlobalFacade.regListener( NotifyConst.EAT_FOOD, onNEatFood );
			this.addEventListener( Event.ENTER_FRAME, onEnterFrame );
		}

		private var frame:int = 0;

		private function onEnterFrame( event:Event ):void
		{
			this.y = _vo.pos.y + 10 * Math.sin( frame / 10 );
			frame++;
		}

		private function onNEatFood( n:Notify ):void
		{
			if( n.data != _vo ) return;
			var foodVO:FoodVO = n.data;
			if( foodVO.num <= 0 )
			{
				this.parent.removeChild( this );
				dispose();
			} else
			{
				var p:Number = foodVO.leftPercent;
				if( p > 2 / 3 ) _foodMc.gotoAndStop( 1 ); else if( p > 1 / 3 ) _foodMc.gotoAndStop( 2 ); else _foodMc.gotoAndStop( 3 );
			}
		}

		public function dispose():void
		{
			this.removeEventListener( Event.ENTER_FRAME, onEnterFrame );
			GlobalFacade.removeListener( NotifyConst.EAT_FOOD, onNEatFood );
		}
	}
}
