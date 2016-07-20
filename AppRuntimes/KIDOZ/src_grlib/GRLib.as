/**
 * Created by rhett on 16/5/13.
 */
package
{

import com.aoaogame.sdk.AnalysisManager;
import com.aoaogame.sdk.UMAnalyticsManager;
import com.kidoz.sdk.api.platforms.SdkController;

import flash.desktop.NativeApplication;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.events.KeyboardEvent;
import flash.system.Capabilities;
import flash.ui.Keyboard;

//	import org.mousebomb.AoaoSelfAd;

import org.mousebomb.DebugHelper;

import org.mousebomb.NotificationPush;

/**
 * 此类提供各种功能，比如广告展示，更多广告，统计，通知等
 */
public class GRLib extends Sprite
{
	private var grConf:GRConfig;

	static var controller:SdkController;


	public function GRLib()
	{
		this.addEventListener( Event.ADDED_TO_STAGE, onStage );
	}

	private function onStage( event:Event ):void
	{
		bindRoot(stage.root);
		new DebugHelper(stage);
	}

	/**
	 * 绑定root 监听事件调用
	 * @param r
	 */
	public function bindRoot( r:IEventDispatcher )
	{
		grConf = new GRConfig();
		//
		r.addEventListener( "GENG_DUO", onGengDuo );
		r.addEventListener( "BANNER", onBanner );
		r.addEventListener( "INTERSTITIAL", onInterstitial );
		// ad
		controller = SdkController.initSdkContoller("5","i0tnrdwdtq0dm36cqcpg6uyuwupkj76s");
		controller.addFeedButton(20,20);
		controller.changeFeedButtonVisibilityState(false);
		//

//			// aoao Ad
//			AoaoSelfAd.init(grConf.aoaoAppID, stage , AoaoSelfAd[grConf.moreClosePos]);
//			// aoao analysis
//			AnalysisManager.instance.setAnalytics(grConf.aoaoAppID, "com.aoaogame.game"+grConf.aoaoAppID+".analysis");
//			// UMAnalytics
//			CONFIG::IOS
//			{
//				UMAnalyticsManager.instance.startWithAppkey(grConf.iosUMeng);
//				UMAnalyticsManager.instance.startSession();
//			}
//			CONFIG::ANDROID
//			{
//				UMAnalyticsManager.instance.startSession();
//			}
		//NOTIFICATION
		CONFIG::ANDROID
		{
			NotificationPush.notifyTomorrow(grConf);
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, onDective);
		}
		//BACK press exit
		CONFIG::ANDROID{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);

		}
		onBanner(null);
	}

	private function onKeyDown( event:KeyboardEvent ):void
	{
		if (event.keyCode == Keyboard.BACK)
		{
			event.preventDefault();
			NativeApplication.nativeApplication.activeWindow.close();
			NativeApplication.nativeApplication.exit();
		}
	}

	private function onDective( event:Event ):void
	{
		CONFIG::ANDROID
		{
			NotificationPush.notifyTomorrow(grConf);
		}
	}
	private var nextInterstitialI:uint = 0;
	private function onInterstitial( event:Event ):void
	{
		trace("GRLib/onInterstitial()");

		if(++nextInterstitialI % grConf.interstitialAdLevel == 0)
		{
			controller.changeFeedButtonVisibilityState(true);
		}
	}

	private function onBanner( event:Event ):void
	{
		trace("GRLib/onBanner()");

		/** Add feed Panel to View  */
		controller.addPanleView(SdkController.PANEL_TYPE_BOTTOM,SdkController.HANDLE_POSITION_END);

		/** Set desired panel color (Optional) */
		controller.setPanelViewColor("#FF9F3087");

	}

	private function onGengDuo( event:Event ):void
	{
		trace("GRLib/onGengDuo()");
//			AoaoSelfAd.showAd(  );
	}

	public static function get showMoreBtn():Boolean
	{
		return false;
//			return AoaoSelfAd.showMoreBtn;
	}

}
}
