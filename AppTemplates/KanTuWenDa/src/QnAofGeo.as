package
{
	import game.AoaoGame;
	import game.GameContext;

	import org.mousebomb.SoundMan;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.text.TextField;

	/**
	 * @author Mousebomb
	 */
	public class QnAofGeo extends AoaoGame
	{
		private var _scene : DisplayObject;
		private var context : GameContext;

		public function QnAofGeo()
		{

			super();
		}

		override protected function start() : void
		{
			super.start();

			context = new GameContext(this);

			SoundMan.init();
			SoundMan.playBgm("bgm.mp3");
			//
			_scene = new UIWelcome();
			addChild(_scene);
			//
			if(CONFIG::DEBUG)
			{
				var tf:TextField = new TextField();
				tf.text = "DEBUG VERSION";
				trace("DEBUG VERSION");
				addChild(tf);
			}
		}

		public function replaceScene(scene : Sprite) : void
		{
			removeChild(_scene);
			_scene = scene;
			addChild(scene);
		}
	}
}
