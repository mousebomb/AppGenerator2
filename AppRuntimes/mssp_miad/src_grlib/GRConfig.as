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

	public var miAppID:String;
	public var miSplashID:String;
	public var miInterstitialID:String;

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

		baiduAndroidAppID = x.@androidBaiduAppID;
		baiduAndroidBanner = x.@androidBaiduBanner;
		baiduAndroidInterstitial = x.@androidBaiduInterstitial;

		miAppID = x.@androidMiAppID;
		miSplashID = x.@androidMiSplash;
		miInterstitialID = x.@androidMiInterstitial;

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
			"baiduAndroidAppID="+baiduAndroidAppID+"\n"+
			"baiduAndroidBanner="+baiduAndroidBanner+"\n"+
			"baiduAndroidInterstitial="+baiduAndroidInterstitial+"\n"+
			"miAppID="+miAppID+"\n"+
			"miSplashID="+miSplashID+"\n"+
			"miInterstitialID="+miInterstitialID+"\n"+
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
