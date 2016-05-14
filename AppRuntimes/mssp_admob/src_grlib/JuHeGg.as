/**
 * Created by rhett on 16/4/21.
 */
package {

import com.aoaogame.sdk.GlobalConfig;

import flash.desktop.NativeApplication;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.system.Capabilities;

import org.mousebomb.DebugHelper;

import so.cuo.platform.admob.Admob;
import so.cuo.platform.admob.AdmobEvent;
import so.cuo.platform.admob.AdmobPosition;
import so.cuo.platform.baidu.BaiDu;
import so.cuo.platform.baidu.BaiDuAdEvent;
import so.cuo.platform.baidu.BaiDuSize;
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

	public static function isIOS():Boolean
	{
		var isIOS:Boolean = Capabilities.os.indexOf( "iPhone" ) != -1;
		if( Capabilities.os.indexOf( "iPad" ) != -1 )
			isIOS = true;
		return isIOS;
	}


	// 应用ID
	private var _appID:int = -1;
	// 默认广告ID
	private var _defBaiduAppID:String = "";
	private var _defBaiduBannerId:String = "";
	private var _defBaiduInterstitialId:String = "";
	private var _defAdmobBannerId:String = "";
	private var _defAdmobInterstitialId:String = "";
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
	public function init( app_id:int, baiduAppID:String,baiduBanner:String,baiduInterstitial:String, admob_banner_id:String, admob_interstitial_id:String ):void
	{
		DebugHelper.log("初始化AD,AppID:"+app_id);
		DebugHelper.log("预设:BAIDU:"+baiduAppID+","+baiduBanner+","+baiduInterstitial +";admobBanner:"+admob_banner_id + ",admob_interstitial="+admob_interstitial_id);
		initANEs();
		// 从后台加载数据 成功或失败都派发对应消息
		_appID = app_id;
		_defBaiduAppID = baiduAppID;
		_defBaiduBannerId = baiduBanner;
		_defBaiduInterstitialId = baiduInterstitial;
		_defAdmobBannerId = admob_banner_id;
		_defAdmobInterstitialId = admob_interstitial_id;

		loadConfigFromAoao();

	}

	/** 木有广告 如果嗷嗷后台没有配置，则返回cNoAd，客户端按默认值显示 */
	public static const ERR_NO_AD:uint = 201;
	public static const SUCC:uint = 0;

	private var tryLoadConfigTime:int = 0;
	private var _admob:Admob;
	private var _baidu:BaiDu;

	private function loadConfigFromAoao():void
	{
		// 加载数据
		var descriptor:XML = NativeApplication.nativeApplication.applicationDescriptor;
		var ns:Namespace = descriptor.namespaceDeclarations()[0];
		var version:String = descriptor.ns::versionNumber.toString();
		_request = new URLRequest( GlobalConfig.GET_AD_DATA_PHP_URL + "?i=" + _appID + "&o=" + Capabilities.os + "&l=" + Capabilities.language + "&v=" + version );
		DebugHelper.log("?i=" + _appID + "&o=" + Capabilities.os + "&l=" + Capabilities.language + "&v=" + version);
		_request.method = URLRequestMethod.GET;
		_urlLoader = new URLLoader();
		_urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
		_urlLoader.load( _request );
		_urlLoader.addEventListener( Event.COMPLETE, urlLoaded );
		_urlLoader.addEventListener( IOErrorEvent.IO_ERROR, onUrlLoadError );
	}

	private function onUrlLoadError( event:IOErrorEvent ):void
	{
		trace( "获得官网广告数据失败：" + event.text );
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
				trace( "官网数据无法解析:" + _urlLoader.data );
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
//				DebugHelper.log(_urlLoader.data);
			var _adObjArr:Array = res.result;
			for( var i:int = 0; i < _adObjArr.length; i++ )
			{
				var eachAdConfig:Object = _adObjArr[i];
				var adtype = eachAdConfig.adtype;
				var bannerKey = eachAdConfig.bannerKey;
				var interstitialKey = eachAdConfig.interstitialKey;
				var bannerPercent = eachAdConfig.bannerPercent;
				var interstitialPercent = eachAdConfig.interstitialPercent;
				if( adtype.toUpperCase() == "ADMOB" )
				{
					_admob.setKeys( bannerKey, interstitialKey );
					_admobBannerPercent = bannerPercent;
					_admobInterstitialPercent = interstitialPercent;
					DebugHelper.log("_admobBannerPercent="+ _admobBannerPercent);
					DebugHelper.log("_admobInterstitialPercent="+ _admobInterstitialPercent);
					DebugHelper.log("_admob.setKeys( "+ bannerKey+", "+ interstitialKey+" );");
				} else if( adtype.toUpperCase() == "BAIDU" )
				{
					_baiduBannerPercent = bannerPercent;
					_baiduInterstitialPercent = interstitialPercent;
					_baidu.setKeys( _defBaiduAppID, _defBaiduBannerId, _defBaiduInterstitialId );
					DebugHelper.log("_baiduBannerPercent="+ _baiduBannerPercent);
					DebugHelper.log("_baiduInterstitialPercent="+ _baiduInterstitialPercent);
					DebugHelper.log("_baidu.setKeys( "+ _defBaiduAppID+", "+ _defBaiduBannerId+", "+ _defBaiduInterstitialId+" );");
				}
			}
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
		_admob.setKeys( _defAdmobBannerId, _defAdmobInterstitialId );
		_baidu.setKeys( _defBaiduAppID, _defBaiduBannerId, _defBaiduInterstitialId );
		DebugHelper.log("useDefaultKeys");
		cacheInterstitial();
	}

	private function initANEs():void
	{
		_admob = Admob.getInstance();
		_baidu = BaiDu.getInstance();
		_admob.addEventListener(AdmobEvent.onInterstitialDismiss, onInterstitialDismissEvent);
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
		cacheInterstitial();
	}

	/**
	 * 显示banner广告
	 * @param horizontal 水平位置
	 * @param vertical 垂直位置
	 */
	public function showBanner( horizontal:String = CENTER, vertical:String = TOP ):void
	{
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
			_admob.showBanner( Admob.BANNER,AdmobPosition[vertical + "_" + horizontal]);
			DebugHelper.log("_admob.showBanner()");
		}

	}

	/**
	 * 隐藏banner广告
	 */
	public function hideBanner():void
	{
		try
		{
			if( _baidu.supportDevice ) _baidu.hideBanner();
			if( _admob.supportDevice ) _admob.hideBanner();
		} catch( error:Error )
		{
		}
	}


	public function showInterstitial():void
	{
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
			DebugHelper.log("_baidu.showInterstitial()");
		} else if( _admob.isInterstitialReady() )
		{
				_admob.showInterstitial();
				DebugHelper.log("baiduNotReady,_admob.showInterstitial()");
			}
		}else{
			if( _admob.isInterstitialReady() )
			{
			_admob.showInterstitial();
			DebugHelper.log("_admob.showInterstitial()");
			} else if( _baidu.isInterstitialReady() )
			{
				_baidu.showInterstitial();
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
		if(!_admob.isInterstitialReady() && _admobInterstitialPercent>0)
		{
			_admob.cacheInterstitial();
			DebugHelper.log("_admob.cacheInterstitial()");
		}
	}
}
}
