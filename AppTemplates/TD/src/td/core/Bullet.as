/**
 * Created by rhett on 14/12/29.
 */
package td.core
{

	import org.mousebomb.framework.GlobalFacade;
	import org.mousebomb.framework.Notify;

	import td.NotifyConst;

	import td.battlefield.model.vo.BulletVO;

	public class Bullet extends BattleSprite
	{
		public function Bullet()
		{
			if(!GlobalFacade.hasListener(NotifyConst.BULLETVO_MOVED,onMoved))
			{
				GlobalFacade.regListener(NotifyConst.BULLETVO_MOVED,onMoved);
			}
		}

		private var _vo :BulletVO;

		public static function create( bulletVO:BulletVO ):Bullet
		{
			var end : Bullet = ReusablePool.getObject(Bullet);
			end._vo = bulletVO;
			end.setMc(TDGame.assetsMan.getTextures("B"+bulletVO.bulletId));
			end.needValidate();
			return end;
		}
		// #3  pool

		override public function dispose():void
		{
			super.dispose();
			ReusablePool.addToPool(this,Bullet);
		}

		//#2 move
		private function onMoved( n :Notify ):void
		{
			if(n.target == _vo)
			{
				needValidate();
			}
		}

		//

		override public function validateNow():void
		{
			super.validateNow();
			x = _vo.x;
			y=_vo.y;
			rotation = _vo.rotation;
		}
	}
}
