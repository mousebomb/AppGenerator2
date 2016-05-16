package {
	import jianbihua.JBHWelcome;

	import org.mousebomb.IFlyIn;
	import org.mousebomb.SoundMan;
	import org.mousebomb.interfaces.IDispose;

	import flash.display.DisplayObject;
	import flash.display.Sprite;

	/**
	 * @author rhett
	 */
	public class JianBiHua extends AoaoGame {
		public static var instance : JianBiHua ;

		public function JianBiHua() {
			super();
			instance = this;
		}

		override protected function start() : void {
			super.start();

			SoundMan.playBgm("bgm.mp3");

			_scene = new JBHWelcome();
			rootView.addChild(_scene);
		}

		private var _scene : DisplayObject;

		public function replaceScene(scene : Sprite) : void {
			(_scene as IDispose).dispose();
			rootView.removeChild(_scene);
			_scene = scene;
			(scene as IFlyIn).flyIn();
			rootView.addChild(scene);
		}
	}
}
