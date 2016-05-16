/**
 * Created by rhett on 14/11/2.
 */
package td.core
{

	import starling.events.TouchPhase;
	import starling.events.TouchEvent;
	import org.mousebomb.framework.GlobalFacade;
	import org.mousebomb.framework.Notify;

	import starling.core.Starling;

	import starling.display.Button;
	import starling.display.MovieClip;
	import starling.events.Event;
	import starling.textures.Texture;

	import td.NotifyConst;

	import td.battlefield.model.vo.TowerVO;

	/**
	 * 塔  有若干个动作状态，单方向，可派发攻击
	 */
	public class Tower extends BattleSprite
	{
//		private static var btnArea;
//		private var btn:Button;

		public function Tower()
		{
////			if( btnArea == null ) btnArea = Texture.empty( 64, 64 );
//			if( btnArea == null ) btnArea = Texture.fromColor(64,64,0xffff0000);//
//			btn = new Button( btnArea );
//			btn.alignPivot();
//			this.addChild( btn );
//			btn.addEventListener( Event.TRIGGERED, onTriggered );
			
//			this.addEventListener(TouchEvent.TOUCH, onTouch);

			GlobalFacade.regListener( NotifyConst.TOWERVO_UPDATED, onTowerUpdate );
			GlobalFacade.regListener( NotifyConst.TOWERVO_STATE_CHANGED, onTowerStateChanged );
		}
		

		private function onTouch(event : TouchEvent) : void
		{
			if(event.getTouch(this,TouchPhase.ENDED))
			{
				GlobalFacade.sendNotify( NotifyConst.TOWER_SLOT_CLICK, this, vo );
			}
		}

		private function onTriggered( event:Event ):void
		{
			GlobalFacade.sendNotify( NotifyConst.TOWER_SLOT_CLICK, this, vo );

		}

		//#1 pool
		override public function dispose():void
		{
			GlobalFacade.removeListener( NotifyConst.TOWERVO_UPDATED, onTowerUpdate );
			GlobalFacade.removeListener( NotifyConst.TOWERVO_STATE_CHANGED, onTowerStateChanged );
			super.dispose();
			ReusablePool.addToPool( this, Tower );
		}

		public static function create( vo:TowerVO ):Tower
		{
			var end:Tower = ReusablePool.getObject( Tower );
			end.vo = vo;
			return end;
		}

		// #2 update by vo 数据

		private var _vo:TowerVO;

		public function get vo():TowerVO
		{
			return _vo;
		}

		public function set vo( value:TowerVO ):void
		{
			_vo = value;
			needValidate();
		}

		private var towerId : int =-1;

		override public function validateNow():void
		{
			super.validateNow();
			if(towerId != _vo.towerId)
			{
				// 换贴图
				if( _vo.towerId == 0 )
				{
					setMc( TDGame.assetsMan.getTextures( "TA0" ) );
				} else
				{
					setMc( TDGame.assetsMan.getTextures( "TA" + _vo.towerId + "_" ) )
				}
				towerId = _vo.towerId;
				animation.loop = false;
				animation.stop();
				animation.addEventListener( Event.COMPLETE, onAtkComplete );
//				setChildIndex( btn, numChildren - 1 );
			}
			this.x = vo.x;
			this.y = vo.y;
		}

		private function onAtkComplete(event : Event) : void
		{
			animation.currentFrame=0;
			animation.stop();
		}

		private function onTowerUpdate( n:Notify ):void
		{
			var towerVO:TowerVO = n.data;
			if( towerVO == vo )
			{
				// 若是升级，则一定towerid不为0，播放升级特效
				if(vo.towerId>0)
				{

					var mc:MovieClip = new MovieClip( TDGame.assetsMan.getTextures( "DefenderBuilt" ) );
					Starling.juggler.add( mc );
					mc.addEventListener( Event.COMPLETE, onDieComplete );
					mc.alignPivot();
					addChild( mc );
				}
				// 更新外观
				needValidate();
			}
		}


		private function onTowerStateChanged( n:Notify ):void
		{
			var towerVO:TowerVO = n.target;
			if( towerVO == vo )
			{
				validateNow();
				if( vo.state == TowerVO.STATE_ATK )
				{
					animation.currentFrame = 0;
					animation.play();
				}
			}
		}

		private function onDieComplete( event:Event ):void
		{
			var mc:MovieClip = (event.currentTarget as MovieClip);
			Starling.juggler.remove( mc );
			mc.removeFromParent( true );

		}
	}
}
