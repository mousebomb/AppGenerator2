/**
 * Created by rhett on 14-7-19.
 */
package
{

	import MO.MOWelcome;

	import flash.display.DisplayObject;
	import flash.display.Sprite;

	import org.mousebomb.IFlyIn;
import org.mousebomb.SoundMan;
	import org.mousebomb.interfaces.IDispose;

	/**
	 * @author rhett
	 */
    public class Game extends AoaoGame
	{
		public static var instance:Game;

		public function Game()
		{
			super();
			instance = this;
        }

		override protected function start():void
		{
			super.start();
			//
			SoundMan.playBgm( "bgm.mp3" );
			_scene = new MOWelcome();
			rootView.addChild( _scene );
		}

		private var _scene:DisplayObject;


		public function replaceScene( scene:Sprite ):void
		{
			(_scene as IDispose).dispose();
			rootView.removeChild( _scene );
			_scene = scene;
			if( scene is IFlyIn )(scene as IFlyIn).flyIn();
			rootView.addChild( scene );
		}

	}
}
