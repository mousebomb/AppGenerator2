package 
{
	import tiezhi.TZWelcome;
	import org.mousebomb.IFlyIn;
	import org.mousebomb.SoundMan;
	import org.mousebomb.interfaces.IDispose;
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	/**
	 * @author rhett
	 */
	public class TieZhi extends AoaoGame
	{
		public static var instance :TieZhi ;
		public function TieZhi()
		{instance = this;
		}

		override protected function start() : void
		{
			super.start();
			
			SoundMan.playBgm("bgm.mp3");
			
			_scene = new TZWelcome();
			rootView.addChild(_scene);
		}
		
		private var _scene : DisplayObject;
		
		
		public function replaceScene(scene : Sprite) : void
		{
			(_scene as IDispose).dispose();
			rootView.removeChild(_scene);
			_scene = scene;
			(scene as IFlyIn).flyIn();
			rootView.addChild(scene);
		}
	
	}
}
