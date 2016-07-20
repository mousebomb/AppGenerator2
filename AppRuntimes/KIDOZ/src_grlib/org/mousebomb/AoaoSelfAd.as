/**
 * Created by rhett on 16/5/15.
 */
package org.mousebomb
{
	import globalAsset.Mask_mc;
	import globalAsset.MyAd_mc;

	import com.aoaogame.sdk.GlobalConfig;
	import com.aoaogame.sdk.util.PopManager;

	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.navigateToURL;
	import flash.system.Capabilities;
	import flash.system.ImageDecodingPolicy;
	import flash.system.LoaderContext;

	public class AoaoSelfAd
	{
		// 内置广告
		static private var _myADRequest : URLRequest;
		static private var _urlLoader : URLLoader = new URLLoader();
		// 广告图片loader
		static private var _picLoader : Loader = new Loader();
		// 广告皮肤
		static private var _myAd_mc : MyAd_mc = new MyAd_mc();
		// 广告容器，addChild _myAd_mc
		static private var _adContainer : DisplayObjectContainer;
		// 内置广告URL和图片，如果无内置广告则more按钮跳转至aoaoGame.com，否则的话显示广告，并且点击广告后跳转到我们指定的游戏
		// errorCode为0，表示没有错误，可以正常解析广告
		static private var _errorCode : int = -1;
		static private var _adObj : Object;
		// 呼叫广告的应用ID
		static private var _appID : int = -1;
		// 关闭按钮位置常量
		static public var RIGHT_TOP : int = 0;
		static public var RIGHT_DOWN : int = 1;
		static public var LEFT_TOP : int = 2;
		static public var LEFT_DOWN : int = 3;
		// 获得自定义广告后的回调，主程序可以根据是否成功获得自定义广告来判断是否显示“更多”按钮等操作，相当于一个后台开关。
		// 函数传出两个参数：
		// 第一个参数代表是否成功获取自定义广告数据：true代表成功获得自定义广告数据，false代表没有
		// 第二个参数代表是否显示more按钮：true代表显示，false代表不显示
		static public var resultFun : Function;
		// 当关闭时候回调 无参数
		static private var _onDismiss:Function;

		// 当前展示的广告
		public function AoaoSelfAd() {
		}

		/**
		 * 初始化，并加载广告
		 * @param appID 本APP的ID
		 * @param container 显示广告的容器
		 * @param closeBtnPosition 关闭按钮位置，默认在右上角，具体位置参数在类常量中定义
		 */
		static public function init(appID : int, container : DisplayObjectContainer,closeBtnPosition : int = 0) : void {
			_appID = appID;
			_adContainer = container;
			// 版本号
			var descriptor : XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns : Namespace = descriptor.namespaceDeclarations()[0];
			var version : String = descriptor.ns::versionNumber.toString();

			// 加载数据
			_myADRequest = new URLRequest(GlobalConfig.AD_PHP_URL + "?i=" + _appID + "&o=" + Capabilities.os + "&l=" + Capabilities.language + "&v=" + version);
			// trace('version: ' + (version));
			// trace('_appID: ' + (_appID));
			_myADRequest.method = URLRequestMethod.GET;
			_urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
			_urlLoader.load(_myADRequest);
			_urlLoader.addEventListener(Event.COMPLETE, urlLoaded);
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, urlLoadError);
			//
			_closeBtnPosition = closeBtnPosition;
		}

		static private function urlLoadError(event : IOErrorEvent) : void {
			_errorCode = -1;
			_adObj = null;
			if (resultFun != null) resultFun(false, false);
		}

		static private function urlLoaded(event : Event) : void {
			// trace('_urlLoader.data: ' + (_urlLoader.data));
			var res : Object = JSON.parse(_urlLoader.data);
			_errorCode = res.errorCode;
			if (_errorCode == 0) {
				_adObj = res.result;
				if (resultFun != null) resultFun(true, true);
				preloadAd();
			} else {
				_adObj = null;
				trace('resultFun: ' + (resultFun));
				if (resultFun != null) resultFun(false, showMoreBtn);
			}
			// trace('_MyAdManagerErrorCode: ' + (_errorCode));
			// trace(_adObj.pic);
			// trace(_adObj.link);
		}

		// 判断是否有自己的广告
		static public function get hasAd() : Boolean {
			if (_errorCode != 0 || _adObj == null) return false;
			return true;
		}

		// 判断是否显示more按钮
		static public function get showMoreBtn() : Boolean {
			// if (_adObj == null || _errorCode == 202) return false;

			// trace('_adObj: ' + (_adObj));
			// if (_adObj == null) {
			// return false;
			// } else {
			// trace('_errorCode: ' + (_errorCode));
			// if (_errorCode == 202) {
			// return false;
			// } else {
			// return true;
			// }
			// }
			// 判断是否显示more按钮
			if (_errorCode == -1 || _errorCode == 202) return false;
			return true;
		}

		static private var isLoading:Boolean = false;
		static private function preloadAd():void
		{
			if(isLoading) return;
			if (_picLoader.content == null) {
				var loaderContext : LoaderContext = new LoaderContext();
				loaderContext.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD;
				_picLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, picLoaded);
				_picLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, picLoading);
				_picLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, picError);
				_picLoader.load(new URLRequest(_adObj.pic), loaderContext);
				isLoading = true;
			} else {
			}
		}

		static private var _closeBtnPosition:int;
		static private function validateCloseBtnPos():void
		{
			if (_closeBtnPosition == RIGHT_TOP) {
				_myAd_mc.close_btn.x = _myAd_mc.width - 25;
				_myAd_mc.close_btn.y = 25;
			} else if (_closeBtnPosition == RIGHT_DOWN) {
				_myAd_mc.close_btn.x = _myAd_mc.width - 25;
				_myAd_mc.close_btn.y = _myAd_mc.height - 25;
			} else if (_closeBtnPosition == LEFT_DOWN) {
				_myAd_mc.close_btn.x = 25;
				_myAd_mc.close_btn.y = _myAd_mc.height - 25;
			} else if (_closeBtnPosition == LEFT_TOP) {
				_myAd_mc.close_btn.x = 25;
				_myAd_mc.close_btn.y = 25;
			}
		}
		/**
		 * 显示广告
		 */
		static public function showAd(onDismissCallback:Function = null) : void {
			if (hasAd == true) {
				_onDismiss = onDismissCallback;
				_adContainer.addChild(_myAd_mc);
				_myAd_mc.x = (_adContainer.stage.stageWidth - _myAd_mc.width) / 2;
				_myAd_mc.y = (_adContainer.stage.stageHeight - _myAd_mc.height) / 2;
				PopManager.show(_myAd_mc, _adContainer, Mask_mc);
				_myAd_mc.close_btn.addEventListener(MouseEvent.CLICK, closeAD);
				validateCloseBtnPos();
			} else {
				navigateToURL(new URLRequest(GlobalConfig.HOMEPAGE_URL + "/?fromid=" + _appID));
			}
		}

		private static function picError(event : IOErrorEvent) : void {
			_myAd_mc.loading_txt.text = "404 Error";
		}

		private static function picLoaded(event : Event) : void {
			Bitmap(_picLoader.content).smoothing = true;

			_myAd_mc.removeChildAt(0);
			_myAd_mc.removeChild(_myAd_mc.loading_txt);
			_myAd_mc.addChildAt(_picLoader, 0);
			_myAd_mc.x = _myAd_mc.y = 0;
			_picLoader.addEventListener(MouseEvent.CLICK, showAdURL);

			_picLoader.width = _adContainer.stage.stageWidth;
			_picLoader.height = _adContainer.stage.stageHeight;
			validateCloseBtnPos();

		}

		private static function showAdURL(event : MouseEvent) : void {
			navigateToURL(new URLRequest(_adObj.link));
		}

		private static function closeAD(event : MouseEvent) : void {
			PopManager.remove(_myAd_mc);
			_adContainer.removeChild(_myAd_mc);
			_myAd_mc.close_btn.removeEventListener(MouseEvent.CLICK, closeAD);
			if(_onDismiss !=null) {_onDismiss();_onDismiss  = null;}
		}

		private static function picLoading(event : ProgressEvent) : void {
			_myAd_mc.loading_txt.text = "loading " + int((event.bytesLoaded / event.bytesTotal) * 100) + " %";
		}
	}
}
