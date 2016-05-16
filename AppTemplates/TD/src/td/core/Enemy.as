/**
 * Created by rhett on 14/11/2.
 */
package td.core
{

	import com.greensock.TweenNano;

	import org.mousebomb.framework.GlobalFacade;
	import org.mousebomb.framework.Notify;

	import org.mousebomb.interfaces.IDispose;

	import starling.core.Starling;

	import starling.display.MovieClip;

	import starling.display.Sprite;
	import starling.textures.Texture;

	import td.NotifyConst;

	import td.battlefield.model.vo.EnemyVO;

	import td.core.ReusablePool;

	/**
	 * 怪，能移动，有左右方向
	 */
	public class Enemy extends BattleSprite implements IDispose
	{

		/**
		 * 创建怪显示对象
		 * @param moveLeft
		 * @param moveRight
		 * @return
		 */
		public static function create( vo:EnemyVO ):Enemy
		{
			var end:Enemy = ReusablePool.getObject( Enemy );
			end.moveLeft = TDGame.assetsMan.getTextures( "MA" + vo.enemyId + "_L" );
			end.moveRight = TDGame.assetsMan.getTextures( "MA" + vo.enemyId + "_R" );
			end._vo = vo;
			return end;
		}

		public function Enemy()
		{
			touchable = false;
			if( !GlobalFacade.hasListener( NotifyConst.ENEMYVO_MOVED, onEnemyMoved ) )
			{
				GlobalFacade.regListener( NotifyConst.ENEMYVO_MOVED, onEnemyMoved );
				GlobalFacade.regListener( NotifyConst.ENEMYVO_ENEMYHIT, onEnemyHit );
			}
		}


		//#1 移动
		public static const DIRECTION_LEFT:uint = 28;
		public static const DIRECTION_RIGHT:uint = 29;
		private var _direction:uint;

		public function get direction():uint
		{
			return _direction;
		}

		public function set direction( value:uint ):void
		{
			if( _direction == value ) return;
			_direction = value;
			if( _direction == DIRECTION_LEFT )
			{
				setMc( moveLeft );
			} else
			{
				setMc( moveRight );
			}
		}

		//

		// #2 纪录材质
		private var moveLeft:Vector.<Texture>;
		private var moveRight:Vector.<Texture>;


		// #3  pool

		override public function dispose():void
		{
			super.dispose();
			ReusablePool.addToPool( this, Enemy );
		}

		//#4 update by vo

		private var _vo:EnemyVO;
		public function get vo():EnemyVO
		{
			return _vo;
		}

		public function set vo( value:EnemyVO ):void
		{
			_vo = value;
			needValidate();
		}

		/**
		 * validate  根据vo
		 */
		override public function validateNow():void
		{
			super.validateNow();
			var toDir:uint = direction;
			if( _vo.x > x )
			{
				toDir = DIRECTION_RIGHT;
			} else if( _vo.x < x )
			{
				toDir = DIRECTION_LEFT;
			}
			direction = toDir;
			//
			x = _vo.x;
			y = _vo.y;
		}

		//# life
		private var lifeBar:LifeBar;

		private function validateLifeBar():void
		{
			if( !lifeBar )
			{
				lifeBar = new LifeBar();
				lifeBar.y = -animation.height / 2;
				addChild(lifeBar);
			}
			lifeBar.ratio = vo.hp / vo.maxHp;
		}

		private function onEnemyMoved( n:Notify ):void
		{
			if( n.target == _vo )
			{
				needValidate();
			}
		}

		private function onEnemyHit( n:Notify ):void
		{
			if( n.target == _vo )
			{
				//
				if( vo.hp < vo.maxHp )
				{
					validateLifeBar();
				}
			}
		}

	}
}

import starling.textures.Texture;
import starling.display.Image;

class LifeBar extends Image
{
	public function LifeBar():void
	{
		super( TDGame.assetsMan.getTexture( "LifeBar0010" ) );
		alignPivot();
	}

	public function set ratio( value:Number ):void
	{
		var life:int = value * 10;
		var lifeStr:String;
		if( life == 10 )
		{
			lifeStr = "10";
		} else
		{
			lifeStr = "0" + life;
		}
		var t : Texture =TDGame.assetsMan.getTexture( "LifeBar00" + lifeStr );
		if(t) texture = t;
	}
}