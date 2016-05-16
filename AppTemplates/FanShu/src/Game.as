package
{

	import YP.MusicModel;
	import YP.YPListen;
	import YP.YPSelect;

	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.filesystem.File;
    import flash.events.*;
	import flash.media.AudioPlaybackMode;
	import flash.media.SoundMixer;
import org.mousebomb.ScreenshotHelper;
import org.mousebomb.SoundMan;
import org.mousebomb.GameConf;


	import org.mousebomb.IFlyIn;
	import org.mousebomb.SoundMan;
	import org.mousebomb.interfaces.IDispose;

	/**
	 * @author rhett
	 */
	public class Game extends Sprite
	{
		public static var instance:Game;

		public function Game()
		{
			instance = this;

			if (stage == null)
			{
				addEventListener(Event.ADDED_TO_STAGE, onStage);
			}
			else
			{
				start();
				// setTimeout(start, 100);
			}
		}

		private function onStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onStage);
			start();
			// setTimeout(start, 100);
		}
        protected var rootView:Sprite;
        protected function start():void
		{
            SoundMixer.audioPlaybackMode = AudioPlaybackMode.AMBIENT;
            rootView = new Sprite();
            this.addChild(rootView);
            GameConf.onStage(stage, rootView);
            SoundMan.init();
			//
			var bgMusic:File = File.applicationDirectory.resolvePath( "res/bgm.mp3" );
			if( bgMusic.exists )
			{
				SoundMan.playBgm( bgMusic.url );
			}
			var list:Array = MusicModel.getInstance().grabMusicList();
			if( list.length > 1 )
			{
				_scene = new YPSelect();
			} else
			{
				// 只有一级则直接进内页
				_scene = new YPListen( list[0] , false );

			}
			rootView.addChild( _scene );
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
            CONFIG::DESKTOP{
                // 桌面 debug ，，要截图功能
                ScreenshotHelper.init(stage);
            }
            //
            NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, onActive);
            NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, onDeactive);

        }
        private function onDeactive(event:Event):void
        {
            SoundMan.deactive();
        }

        private function onActive(event:Event):void
        {
            SoundMan.active();
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
