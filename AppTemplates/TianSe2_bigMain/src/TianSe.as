package {
	import com.aoaogame.sdk.AnalysisManager;
	import com.aoaogame.sdk.UMAnalyticsManager;
	import com.aoaogame.sdk.adManager.MyAdManager;
	import org.mousebomb.adservice.NotificationPush;

	import org.mousebomb.IFlyIn;
	import org.mousebomb.Localize;
	import org.mousebomb.MainView;
	import org.mousebomb.ScreenshotHelper;
	import org.mousebomb.GameConf;
	import org.mousebomb.adservice.AdFactory;
	import org.mousebomb.interfaces.IDispose;

	import flash.desktop.NativeApplication;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.media.AudioPlaybackMode;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.ui.Keyboard;

	/**
	 * @author Mousebomb
	 */
	public class TianSe extends Sprite
	{
		private var _scene : DisplayObject;
		private var bgm : Sound;

		private var channel : SoundChannel;

		public function TianSe()
		{
			var bg : Bg = new Bg();
			addChild(bg);
			addEventListener(Event.ADDED_TO_STAGE, onStage);

			SoundMixer.audioPlaybackMode = AudioPlaybackMode.AMBIENT;
		}

		private function start() : void
		{
			bgm = new Sound();
			bgm.load(new URLRequest("bgm.mp3"));
			channel=bgm.play(0, int.MAX_VALUE);
			// _loader = new Loader();
			// //  _loader.load(new URLRequest("color.swf"));
			// addChild(_loader);
			//

			_scene = new MainView();
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
			if(channel) channel.stop();
		}

		private function onActive(event : Event) : void
		{
			if(channel) channel.stop();
				channel=bgm.play(0, int.MAX_VALUE);
		}

		private function onStage(event : Event) : void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onStage);
			GameConf.onStage(stage, this);
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
