/**
 * Created by rhett on 16/5/14.
 */
package
{

	import flash.system.Capabilities;

	import org.mousebomb.DebugHelper;

	public class GRConfig
	{
		[Embed(source="grconf.xml",mimeType="application/octet-stream")]
		public var GRConfXML:Class;
		public var baiduAndroidAppID:String;
		public var baiduAndroidBanner:String;
		public var baiduAndroidInterstitial:String;

		public var inmobiAndroidAccountID:String;
		public var inmobiAndroidBanner:String;
		public var inmobiAndroidInterstitial:String;

		public var baiduIOSAppID:String;
		public var baiduIOSBanner:String;
		public var baiduIOSInterstitial:String;
		public var inmobiIOSAccountID:String;
		public var inmobiIOSBanner:String;
		public var inmobiIOSInterstitial:String;

		public var iosUMeng:String ;

		public var aoaoAppID : int ;

		public var interstitialAdLevel:int;
		public var bannerV:String;
		public var bannerH:String;
		public var moreClosePos:String;

		public var notificationTitle:String;
		public var notificationAction:String;
		public function GRConfig()
		{
			var x:XML = XML(new GRConfXML());

			baiduIOSAppID = x.@iosBaiduAppID;
			baiduIOSBanner = x.@iosBaiduBanner;
			baiduIOSInterstitial = x.@iosBaiduInterstitial;
			baiduAndroidAppID = x.@androidBaiduAppID;
			baiduAndroidBanner = x.@androidBaiduBanner;
			baiduAndroidInterstitial = x.@androidBaiduInterstitial;

			inmobiIOSAccountID = x.@iosInmobiAccount;
			inmobiIOSBanner = x.@iosInmobiBanner;
			inmobiIOSInterstitial = x.@iosInmobiInterstitial;
			inmobiAndroidAccountID = x.@androidInmobiAccount;
			inmobiAndroidBanner = x.@androidInmobiBanner;
			inmobiAndroidInterstitial = x.@androidInmobiInterstitial;

			iosUMeng = x.@iosUMeng;
			aoaoAppID = x.@appID;
			interstitialAdLevel = x.@interstitialAdLevel;
			bannerH = x.@bannerH;
			bannerV = x.@bannerV;
			moreClosePos = x.@moreClosePos;

			if (Capabilities.language == "zh-CN"
					|| Capabilities.language == "zh-TW"
			) {
				notificationTitle= x.@notificationTitle;
				notificationAction= x.@notificationAction;
			} else {
				notificationTitle= x.@notificationTitleEn;
				notificationAction= x.@notificationActionEn;
			}
			DebugHelper.log(
			"baiduIOSAppID="+baiduIOSAppID+"\n"+
			"baiduIOSBanner="+baiduIOSBanner+"\n"+
			"baiduIOSInterstitial="+baiduIOSInterstitial+"\n"+
			"baiduAndroidAppID="+baiduAndroidAppID+"\n"+
			"baiduAndroidBanner="+baiduAndroidBanner+"\n"+
			"baiduAndroidInterstitial="+baiduAndroidInterstitial+"\n"+
			"inmobiIOSBanner="+inmobiIOSBanner+"\n"+
			"inmobiIOSInterstitial="+inmobiIOSInterstitial+"\n"+
			"inmobiAndroidBanner="+inmobiAndroidBanner+"\n"+
			"inmobiAndroidInterstitial="+inmobiAndroidInterstitial+"\n"+
			"iosUMeng="+iosUMeng+"\n"+
			"aoaoAppID="+aoaoAppID+"\n"+
			"interstitialAdLevel="+interstitialAdLevel+"\n"+
			"bannerV="+bannerV+" "+
			"bannerH="+bannerH+"\n"+
			"moreClosePos="+moreClosePos+"\n"+
			"notificationTitle="+notificationTitle+"\n"+
			"notificationAction="+notificationAction+"\n"
		);
		}

	}
}
