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

		public var KIDOZ_PUBLISHERID:String;
		public var KIDOZ_SECURITY_TOKEN:String;

		public var iosUMeng:String ;

		public var aoaoAppID : int ;

		//秒
		public var interstitialAdCd:int;
		public var panelType:int;
		public var handlePosition:int;
		public var panelColor:String;
		public var bannerPosition:int;

		public var notificationTitle:String;
		public var notificationAction:String;
		public function GRConfig()
		{
			var x:XML = XML(new GRConfXML());

			KIDOZ_PUBLISHERID = x.@KIDOZ_PUBLISHERID;
			KIDOZ_SECURITY_TOKEN = x.@KIDOZ_SECURITY_TOKEN;

			iosUMeng = x.@iosUMeng;
			aoaoAppID = x.@appID;
			interstitialAdCd = x.@interstitialAdCd;
			panelType = x.@panelType;
			handlePosition = x.@handlePosition;
			panelColor = x.@panelColor;
			bannerPosition = x.@bannerPosition;

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
			"KIDOZ_PUBLISHERID="+KIDOZ_PUBLISHERID+"\n"+
			"KIDOZ_SECURITY_TOKEN="+KIDOZ_SECURITY_TOKEN+"\n"+
			"iosUMeng="+iosUMeng+"\n"+
			"aoaoAppID="+aoaoAppID+"\n"+
			"interstitialAdCd="+interstitialAdCd+"\n"+
			"panelType="+panelType+"\n"+
			"handlePosition="+handlePosition+" "+
			"panelColor="+panelColor+" "+
			"notificationTitle="+notificationTitle+"\n"+
			"notificationAction="+notificationAction+"\n"
		);
		}

	}
}
