/**
 * Created by rhett on 14/11/2.
 */
package td.core
{

	import org.mousebomb.interfaces.IDispose;

	import starling.core.Starling;
	import starling.display.MovieClip;

	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.textures.Texture;

	import td.core.ReusablePool;

	public class BattleSprite extends Sprite
	{
		protected  var animation :MovieClip;
		public function BattleSprite()
		{
		}


		protected function setMc( textures :Vector.<Texture> ):void
		{
			var oldIndex :int = -1;
			if(animation != null)
			{
				Starling.juggler.remove(animation);
				oldIndex = animation.parent.getChildIndex(animation);
				animation.removeFromParent(true);
			}
			animation = new MovieClip( textures);
			// 注册点居中
//			animation.x = textures[0].width /2;
//			animation.y = textures[0].height /2;
			animation.alignPivot();
			if(oldIndex>-1)
				addChildAt(animation,oldIndex);
			else
				addChild(animation);
			Starling.juggler.add(animation);
			animation.touchable=this.touchable;
		}


		// +++++++  feature 1:  delay validate
		private var _needValidate:Boolean = false;

		public function needValidate():void
		{
			if( _needValidate ) return;
			_needValidate = true;
			addEventListener( EnterFrameEvent.ENTER_FRAME, onBatchValidate );
		}

		private function onBatchValidate( event:EnterFrameEvent ):void
		{
			removeEventListener( EnterFrameEvent.ENTER_FRAME, onBatchValidate );
			if( _needValidate )
			{
				validateNow();
			}
		}

		public function validateNow():void
		{
			_needValidate = false;
			// other
		}


	}
}
