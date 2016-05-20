/**
 * Created by rhett on 16/5/17.
 */
package yizhidaquan
{

	import flash.desktop.NativeApplication;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.media.AudioPlaybackMode;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.net.URLRequest;

	import org.mousebomb.GameConf;
	import org.mousebomb.IFlyIn;
	import org.mousebomb.SoundMan;

	import org.mousebomb.tianse.TSLevel;
	import org.mousebomb.ScreenshotHelper;
	import org.mousebomb.interfaces.IDispose;
	import org.mousebomb.wenda.TimuModel;
	import org.mousebomb.wenda.TimuService;

	public class YiZhiDaQuan extends Sprite
	{
		public function YiZhiDaQuan()
		{
			super();
			if(stage)
			{
				start();
			}else{
				addEventListener(Event.ADDED_TO_STAGE, onStage);
			}
			instance = this;
		}
		public static var instance :YiZhiDaQuan;
		private var _scene : DisplayObject;
		private var bgm : Sound;

		private var channel : SoundChannel;

		private function start() : void
		{
			GameConf.onStage(stage, this);

			SoundMixer.audioPlaybackMode = AudioPlaybackMode.AMBIENT;

			SoundMan.init();
			SoundMan.playBgm("bgm.mp3");

			_scene = new YZWelcome();
			addChild(_scene);

			CONFIG::DESKTOP{
				// 桌面 debug ，，要截图功能
				ScreenshotHelper.init(stage);
			}

			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, onActive);
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, onDective);

		}

		private function onDective(event : Event) : void
		{
			SoundMan.deactive();
		}

		private function onActive(event : Event) : void
		{
			SoundMan.active();
		}

		private function onStage(event : Event) : void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onStage);
			// setTimeout(start, 100);
			start();
		}

		public function replaceScene(scene : Sprite) : void
		{
			(_scene as IDispose).dispose();
			removeChild(_scene);
			_scene = scene;
			(scene as IFlyIn).flyIn();
			addChild(scene);
		}

	}
}
