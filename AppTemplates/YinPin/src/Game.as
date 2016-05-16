package 
{

	import YP.MusicModel;
	import YP.YPSelect;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.media.AudioPlaybackMode;
	import flash.media.SoundMixer;

	import org.mousebomb.IFlyIn;
	import org.mousebomb.interfaces.IDispose;

	/**
	 * @author rhett
	 */
	public class Game extends AoaoGame
	{
		public static var instance :Game ;
		public function Game()
		{instance = this;
		}

		override protected function start() : void
		{
			super.start();
			SoundMixer.audioPlaybackMode = AudioPlaybackMode.MEDIA;
			MusicModel.getInstance().grabMusicList();
			_scene = new YPSelect();
			rootView.addChild(_scene);
		}
		
		private var _scene : DisplayObject;
		
		
		public function replaceScene(scene : Sprite) : void
		{
			(_scene as IDispose).dispose();
			rootView.removeChild(_scene);
			_scene = scene;
			if(scene is IFlyIn)(scene as IFlyIn).flyIn();
			rootView.addChild(scene);
		}
	
	}
}
