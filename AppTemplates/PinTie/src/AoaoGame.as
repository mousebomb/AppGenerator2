package {
	import com.aoaogame.sdk.AnalysisManager;
	import com.aoaogame.sdk.UMAnalyticsManager;
	import com.aoaogame.sdk.adManager.MyAdManager;
	import org.mousebomb.adservice.NotificationPush;

	import org.mousebomb.GameConf;
	import org.mousebomb.Localize;
	import org.mousebomb.ScreenshotHelper;
	import org.mousebomb.SoundMan;
	import org.mousebomb.adservice.AdFactory;

	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.media.AudioPlaybackMode;
	import flash.media.SoundMixer;
	import flash.ui.Keyboard;

/**
 * @author Mousebomb
 */
public class AoaoGame extends Sprite
{


    protected var rootView:Sprite;

    public function AoaoGame()
    {
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

    protected function start():void
    {
        SoundMixer.audioPlaybackMode = AudioPlaybackMode.AMBIENT;
        rootView = new Sprite();
        this.addChild(rootView);
        GameConf.onStage(stage, rootView);
        SoundMan.init();

        CONFIG::DESKTOP{
			// 桌面 debug ，，要截图功能
			ScreenshotHelper.init(stage);
		}

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

}
}
