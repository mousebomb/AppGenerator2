/**
 * Created by rhett on 16/4/21.
 */
package org.mousebomb {


	import com.inmobi.plugin.adobeair.InMobi;
	import com.inmobi.plugin.adobeair.InMobiEvents;

	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.system.Capabilities;

	import so.cuo.platform.baidu.BaiDu;
	import so.cuo.platform.baidu.BaiDuAdEvent;
	import so.cuo.platform.baidu.RelationPosition;

	public class JuHeGg extends EventDispatcher
{
	// ===========banner广告的位置===========
	public static const LEFT:String = "LEFT";
	public static const RIGHT:String = "RIGHT";
	public static const CENTER:String = "CENTER";
	public static const TOP:String = "TOP";
	public static const BOTTOM:String = "BOTTOM";
	public static const MIDDLE:String = "MIDDLE";
	// ===========广告类型===========
	// 适用于手机的小型条状banner
	public static const BANNER:String = "BANNER";
	// 适用于PAD的中型条状banner
	public static const IAB_BANNER:String = "IAB_BANNER";
	// 铺满屏幕的banner，在ipad上，百度和admob都不能用。。。
	public static const SMART_BANNER:String = "SMART_BANNER";
	// 适用于PAD的大型条状banner
	public static const IAB_LEADERBOARD:String = "IAB_LEADERBOARD";
	// 方形banner
	public static const IAB_MRECT:String = "IAB_MRECT";
	// ===========自定义事件===========
	// 从官网获取广告数据成功
	public static const GET_DATA_SUCCESS:String = "AD_MANAGER_GET_DATA_SUCCESS";
	// 从官网获取广告数据失败
	public static const GET_DATA_FAIL:String = "AD_MANAGER_GET_DATA_FAIL";
	// 从广告平台获取广告失败
	public static const GET_AD_FAIL:String = "AD_MANAGER_GET_AD_FAIL";
	// 单例
	private static var _instance:JuHeGg;

		//
	private static const INMOBI_BANNER_CODING_ID:String = "InmobiBanner";
	private static const INMOBI_INTERSTITIAL_CODING_ID:String = "InmobiInterstitial";
		private var isInMobiBannerCreated:Boolean=false;

	/** 查询广告配置  http://www.aoaogame.com/s/get-aac.php?i=2&o=i&l=cn&v=1.0 */
	public static var GET_APP_AD_CONF_URL:String = "http://www.aoaogame.com/s/get-aac.php";


	public static function get instance():JuHeGg
	{
		if( _instance == null )
			_instance = new JuHeGg();
		return _instance;
	}

	public function JuHeGg()
	{
		if( _instance != null )
			throw new Error( 'singleton' );
	}

	public static function getLang():String
	{
		switch(Capabilities.language)
		{
			case "zh-CN":
			case "zh-TW":
				return 'cn';
				break;
			default:
				return 'en';
		}
	}
	public static function getOS():String
	{
		CONFIG::ANDROID{return "a";}
		CONFIG::IOS{return "i";}
	}


	// 应用ID
	private var _appID:int = -1;
	// 默认广告ID
	private var _defBaiduAppID:String = "";
	private var _defBaiduBannerId:String = "";
	private var _defBaiduInterstitialId:String = "";
	private var _defInmobiAccountID:String = "";
	private var _defInmobiBannerId:String = "";
	private var _defInmobiInterstitialId:String = "";
	private var _admobBannerPercent :int = 50;
	private var _admobInterstitialPercent :int = 50;
	private var _baiduBannerPercent :int = 50;
	private var _baiduInterstitialPercent :int = 50;
	private var _urlLoader:URLLoader;
	private var _request:URLRequest;


	/**
	 * 初始化广告 注意此版本不受后台控制百度ID
	 * @param app_id 应用ID。
	 */
	public function init( app_id:int, baiduAppID:String,baiduBanner:String,baiduInterstitial:String, inmobiAccountID:String,inmobi_banner_id:String, inmobi_interstitial_id:String ):void
	{
		DebugHelper.log("初始化AD,AppID:"+app_id);
		DebugHelper.log("预设:BAIDU:"+baiduAppID+","+baiduBanner+","+baiduInterstitial +";admobBanner:"+inmobi_banner_id + ",admob_interstitial="+inmobi_interstitial_id);
		initANEs();
		// 从后台加载数据 成功或失败都派发对应消息
		_appID = app_id;
		_defBaiduAppID = baiduAppID;
		_defBaiduBannerId = baiduBanner;
		_defBaiduInterstitialId = baiduInterstitial;
		_defInmobiAccountID = inmobiAccountID;
		_defInmobiBannerId = inmobi_banner_id;
		_defInmobiInterstitialId = inmobi_interstitial_id;

		loadConfigFromAoao();

	}

	/** 木有广告 如果嗷嗷后台没有配置，则返回cNoAd，客户端按默认值显示 */
	public static const ERR_NO_AD:uint = 201;
	public static const SUCC:uint = 0;

	private var tryLoadConfigTime:int = 0;
	private var _inMobi:InMobi;
	private var _baidu:BaiDu;

	private function loadConfigFromAoao():void
	{
		// 加载数据
		var descriptor:XML = NativeApplication.nativeApplication.applicationDescriptor;
		var ns:Namespace = descriptor.namespaceDeclarations()[0];
		var version:String = descriptor.ns::versionNumber.toString();
		_request = new URLRequest(GET_APP_AD_CONF_URL);
		var vars :URLVariables = new URLVariables();
		vars.i = _appID;
		vars.o= getOS();
		vars.l= getLang();
		vars.v= version;
		_request.data = vars;
		DebugHelper.log(vars.toString());
		_request.method = URLRequestMethod.GET;
		_urlLoader = new URLLoader();
		_urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
		_urlLoader.load( _request );
		_urlLoader.addEventListener( Event.COMPLETE, urlLoaded );
		_urlLoader.addEventListener( IOErrorEvent.IO_ERROR, onUrlLoadError );
	}

	private function onUrlLoadError( event:IOErrorEvent ):void
	{
		DebugHelper.log( "获得官网广告数据失败：" + event.text );
		useDefaultKeys();
		dispatchEvent( new Event( GET_DATA_FAIL ) );
	}

	private function urlLoaded( event:Event ):void
	{
		// trace('_urlLoader.data: ' + (_urlLoader.data));
		var res:Object;
		try
		{
			res = JSON.parse( _urlLoader.data );
		} catch( e:* )
		{
			// 有时候被电信劫持，导致拿到的数据不是json，要重试
			if( ++tryLoadConfigTime > 2 )
			{
				DebugHelper.log( "官网数据无法解析:" + _urlLoader.data );
				dispatchEvent( new Event( GET_DATA_FAIL ) );
			} else
			{
				loadConfigFromAoao();
			}
			return;
		}
		var _errorCode:int = res.errorCode;
		if( _errorCode == SUCC )
		{
			//result   Array of  {"adtype":"ADMOB","bannerKey":"ca-app-pub-3981702146870599\/5554406619","bannerPercent":"0","interstitialPercent":"0","interstitialKey":"ca-app-pub-3981702146870599\/7031139812"}
			DebugHelper.log(_urlLoader.data);
			_inMobi.initialize(_defInmobiAccountID);
			var baiduAppID :String = res.result.msspAppID;
			var baiduBannerID :String = res.result.msspBannerID;
			var baiduInterstitialID :String = res.result.msspInterstitialID;
			_baidu.setKeys( baiduAppID, baiduBannerID, baiduInterstitialID );
			_baiduBannerPercent = res.result.baiduBannerPercent;
			_admobBannerPercent = res.result.admobBannerPercent;
			_baiduInterstitialPercent= res.result.baiduInterstitialPercent;
			_admobInterstitialPercent= res.result.admobInterstitialPercent;
			DebugHelper.log("MSSPKey="+ baiduAppID+","+baiduBannerID+","+baiduInterstitialID);
			DebugHelper.log("_admobInterstitialPercent="+ _admobInterstitialPercent);
			DebugHelper.log("_baiduInterstitialPercent="+ _baiduInterstitialPercent);
			DebugHelper.log("_admobBannerPercent="+ _admobBannerPercent);
			DebugHelper.log("_baiduBannerPercent="+ _baiduBannerPercent);
			cacheInterstitial();
			dispatchEvent( new Event( GET_DATA_SUCCESS ) );
		} else
		{
			useDefaultKeys();
			dispatchEvent( new Event( GET_DATA_FAIL ) );
		}
	}

	private function useDefaultKeys():void
	{
		_inMobi.initialize(_defInmobiAccountID);
		_baidu.setKeys( _defBaiduAppID, _defBaiduBannerId, _defBaiduInterstitialId );
		DebugHelper.log("useDefaultKeys");
		cacheInterstitial();
	}

	private function initANEs():void
	{
		_inMobi = InMobi.getInstance();
		_baidu = BaiDu.getInstance();
		_inMobi.addEventListener(InMobiEvents.INTERSTITIAL_WILL_DISMISS, onInterstitialDismissEvent);
		_baidu.addEventListener(BaiDuAdEvent.onInterstitialDismiss, onInterstitialDismissEvent);
		_baidu.addEventListener(BaiDuAdEvent.onBannerFailedReceive, onBaiDuFailedReceive);
		_baidu.addEventListener(BaiDuAdEvent.onBannerReceive, onBaiDuReceive);
		_baidu.addEventListener(BaiDuAdEvent.onInterstitialReceive, onBaiDuReceive);
		_baidu.addEventListener(BaiDuAdEvent.onInterstitialFailedReceive, onBaiDuFailedReceive);
	}

	private function onBaiDuReceive( event:BaiDuAdEvent ):void
	{
		DebugHelper.log(event.type);

	}

	private function onBaiDuFailedReceive( event:BaiDuAdEvent ):void
	{
		DebugHelper.log(event.type);
	}

	private function onInterstitialDismissEvent( event:* ):void
	{
		if(shouldRestoreBanner) showBanner(bannerHorizontal,bannerVertical);
		cacheInterstitial();
	}
	private function onSelfAdDismiss():void
	{
		onInterstitialDismissEvent(null);
	}

	// 开启过banner的话，就会一直恢复
	private var shouldRestoreBanner :Boolean = false;
	private var bannerHorizontal:String;
	private var bannerVertical:String;
	/**
	 * 显示banner广告
	 * @param horizontal 水平位置
	 * @param vertical 垂直位置
	 */
	public function showBanner( horizontal:String = CENTER, vertical:String = TOP ):void
	{
		bannerHorizontal = horizontal;
		bannerVertical = vertical;
		hideBanner();
		if(_admobBannerPercent==0 && _baiduBannerPercent==0) return;
		var roll:int = Math.random()* (_admobBannerPercent+_baiduBannerPercent);
		var isBaidu:Boolean ;
		if(roll < _admobBannerPercent)
		{
			isBaidu = false;
		}else{
			isBaidu = true;
		}
		if(isBaidu){
			_baidu.showBanner( BaiDu.BANNER, RelationPosition[vertical + "_" + horizontal]  );
//			_baidu.showBanner( BaiDu.BANNER, RelationPosition.BOTTOM_CENTER );
			DebugHelper.log("_baidu.showBanner()");
		}else{
			if(!isInMobiBannerCreated)
			{
				_inMobi.createBanner(320,50,_defInmobiBannerId,INMOBI_BANNER_CODING_ID);
				isInMobiBannerCreated=true;
			}
			_inMobi.loadBanner(INMOBI_BANNER_CODING_ID);
			DebugHelper.log("_inMobi.showBanner()");
		}
		shouldRestoreBanner = true;

	}

	/**
	 * 隐藏banner广告
	 */
	public function hideBanner():void
	{
		try
		{
			if( _baidu.supportDevice ) _baidu.hideBanner();
			if( isInMobiBannerCreated ) _inMobi.removeBanner(INMOBI_BANNER_CODING_ID);
		} catch( error:Error )
		{
		}
	}

	//自家广告显示一次就不出了，标记
	private var shaShown:Boolean = false;
	public function showInterstitial():void
	{
		// 第一次优先显示自家广告；但只显示一次，之后除非手动点更多按钮，否则都是第三方广告
		if( shaShown==false && AoaoSelfAd.hasAd && AoaoSelfAd.showMoreBtn )
		{
			AoaoSelfAd.showAd(onSelfAdDismiss);
			shaShown = true;
			hideBanner();
			return ;
		}
		if(_admobInterstitialPercent==0 && _baiduInterstitialPercent==0) return;

		var roll:int = Math.random()* (_admobInterstitialPercent+_baiduInterstitialPercent);
		var isBaidu:Boolean ;
		if(roll < _admobInterstitialPercent)
		{
			isBaidu = false;
			DebugHelper.log("roll="+roll+" admob");
		}else{
			isBaidu = true;
			DebugHelper.log("roll="+roll+" baidu");
		}

		if(isBaidu){
			if( _baidu.isInterstitialReady() )
			{
				_baidu.showInterstitial();
				hideBanner();
				DebugHelper.log("_baidu.showInterstitial()");
			} else if( _inMobi.isInterstitialReady(INMOBI_INTERSTITIAL_CODING_ID)  && _admobInterstitialPercent>0 )
			{
				_inMobi.showInterstitial(INMOBI_INTERSTITIAL_CODING_ID);
				hideBanner();
				DebugHelper.log("baiduNotReady,_inMobi.showInterstitial()");
			}
		}else{
			if( _inMobi.isInterstitialReady(INMOBI_INTERSTITIAL_CODING_ID))
			{
				_inMobi.showInterstitial(INMOBI_INTERSTITIAL_CODING_ID);
				hideBanner();
				DebugHelper.log("_inMobi.showInterstitial()");
			} else if( _baidu.isInterstitialReady() && _baiduInterstitialPercent>0)
			{
				_baidu.showInterstitial();
				hideBanner();
				DebugHelper.log( "admobNotReady,_baidu.showInterstitial()" );
			}
		}
	}

	public function cacheInterstitial():void
	{
		if(!_baidu.isInterstitialReady() && _baiduInterstitialPercent>0)
		{
			_baidu.cacheInterstitial();
			DebugHelper.log("_baidu.cacheInterstitial()");
		}
		if(!_inMobi.isInterstitialReady(INMOBI_INTERSTITIAL_CODING_ID) && _admobInterstitialPercent>0)
		{
			_inMobi.loadInterstitial(_defInmobiInterstitialId,INMOBI_INTERSTITIAL_CODING_ID);
			DebugHelper.log("_inMobi.cacheInterstitial()");
		}
	}
}
}
