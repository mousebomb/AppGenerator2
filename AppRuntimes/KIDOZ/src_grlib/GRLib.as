/**
 * Created by rhett on 16/5/13.
 */
package
{

	import com.aoaogame.sdk.UMAnalyticsManager;
	import com.kidoz.sdk.api.platforms.SdkController;

	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	import org.mousebomb.DebugHelper;
	import org.mousebomb.NotificationPush;
	import org.mousebomb.ane.umeng.Umeng;

	//	import org.mousebomb.AoaoSelfAd;

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
			controller = SdkController.initSdkContoller(grConf.KIDOZ_PUBLISHERID,grConf.KIDOZ_SECURITY_TOKEN);
			controller.loadInterstitialView(false);
			//

			// UMAnalytics
			CONFIG::IOS
			{
				UMAnalyticsManager.instance.startWithAppkey(grConf.iosUMeng);
				UMAnalyticsManager.instance.startSession();
			}
			CONFIG::ANDROID
			{
				Umeng.getInstance().onResume();
			}
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, onDective);
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, onActive);
			//NOTIFICATION
			CONFIG::ANDROID
			{
				NotificationPush.notifyTomorrow(grConf);
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
		private function onActive( event:Event ):void
		{
			CONFIG::ANDROID{
				Umeng.getInstance().onResume();
			}
		}

		private function onDective( event:Event ):void
		{
			CONFIG::ANDROID
			{
				NotificationPush.notifyTomorrow(grConf);
				Umeng.getInstance().onPause();
			}
		}
		private var lastInterstitialDisplayedTime:Date = new Date();
		private function onInterstitial( event:Event ):void
		{
			trace("GRLib/onInterstitial()");
			var now :Date = new Date();
			if( now.valueOf()- lastInterstitialDisplayedTime.valueOf() >= grConf.interstitialAdCd*1000 )
			{
				showInterstitial( now );
			}else{
				//CD
				DebugHelper.log("GRLib/onInterstitial() CD ing: left=" +( now.valueOf()- lastInterstitialDisplayedTime.valueOf() ));
			}
		}

		private function showInterstitial( now:Date ):void
		{
			if( controller.getIsInterstitialLoaded() )
			{
				controller.showInterstitialView();
				lastInterstitialDisplayedTime = now;
				DebugHelper.log( "showInterstitial" );
			} else
			{
				DebugHelper.log( "loadInter" );
				controller.loadInterstitialView( false );
			}
		}

		private function onBanner( event:Event ):void
		{
			trace("GRLib/onBanner()");

			CONFIG::ANDROID{
				controller.addPanleView(grConf.panelType,grConf.handlePositionAndroid);
				//安卓上还有banner
				controller.addBannerView(grConf.bannerPosition);
			}
			CONFIG::IOS{
				//iOS上必须在下方
				controller.addPanleView(SdkController.PANEL_TYPE_BOTTOM,grConf.handlePositionIOS);
			}
			controller.setPanelViewColor(grConf.panelColor);

		}

		private function onGengDuo( event:Event ):void
		{
			trace("GRLib/onGengDuo()");
			showInterstitial(new Date());
//			AoaoSelfAd.showAd(  );
		}

		public static function get showMoreBtn():Boolean
		{
			return controller.getIsInterstitialLoaded();
//			return AoaoSelfAd.showMoreBtn;
		}

	}
}
