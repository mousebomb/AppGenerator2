/**
 * Created by rhett on 14-7-19.
 */
package org.mousebomb.adservice
{
import com.aoaogame.sdk.adManager.AdManager;
import org.mousebomb.DebugHelper;
import org.mousebomb.GameConf;
    import org.mousebomb.DebugHelper;
import flash.system.Capabilities;

	import flash.utils.setTimeout;

	public class AdFactory
	{
		public function AdFactory()
		{
				trace("桌面调试模式，不加载广告");
		}



		public function runBanner() : void
		{
            if (CONFIG::DESKTOP) return ;
            if(isAdConfigLoading ) return ;

            //AdManager.instance.showBanner
            //    (
            //        AdManager.BANNER,
            //        AdManager.CENTER,
            //        GameConf.IS_BANNER_BOTTOM?AdManager.BOTTOM:AdManager.TOP
            //    );
		}

        private var nextInterstitialI:uint = 0;

        public function runInterstitial() : void
		{
            if (CONFIG::DESKTOP) return ;
            if(isAdConfigLoading ) return ;

            //if(++nextInterstitialI % GameConf.INTERSTITIAL_AD_LEVEL == 0)
            //{
            //    try{
            //        AdManager.instance.showInterstitial();
            //        // 若是顶部banner，防止挡住插屏关闭按钮，要hide
            //        if(!GameConf.IS_BANNER_BOTTOM) AdManager.instance.hideBanner();
            //    }catch(e:*){}
            //}
		}
	}
}
