package
{
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.display.Loader;
	import flash.display.Sprite;

	/**
	 * @author Mousebomb
	 */
	public class SwfLoaderForAPK extends Sprite
	{
		private static const RATE_16_9 : Number = 16 / 9;
		private static const RATE_3_2 : Number = 3 / 2;
		private static const RATE_4_3 : Number = 4 / 3;
		var picLoader : Loader = new Loader();
		private var whrate : Number;
		private var isLandscape : Boolean;
		
		private var mainLoader:Loader;

		public function SwfLoaderForAPK()
		{
			if (stage)
			{
				start();
			}
			else
			{
				addEventListener(Event.ADDED_TO_STAGE, onStage);
			}
		}

		private function onStage(event : Event = null) : void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onStage);
			start();
		}

		private function start() : void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			// 是否横屏设备
			isLandscape = stage.fullScreenWidth > stage.fullScreenHeight;
			trace('stage.fullScreenHeight: ' + (stage.fullScreenHeight));
			trace('stage.fullScreenWidth: ' + (stage.fullScreenWidth));
			var shortLen : Number;
			var longLen : Number;
			// 宽高比总用长边除以短边,外部图片总是竖屏
			if (isLandscape)
			{
				whrate = stage.fullScreenWidth / stage.fullScreenHeight;
				longLen = stage.fullScreenWidth;
				shortLen = stage.fullScreenHeight;
			}
			else
			{
				whrate = stage.fullScreenHeight / stage.fullScreenWidth;
				longLen = stage.fullScreenHeight;
				shortLen = stage.fullScreenWidth;
			}

			var request : URLRequest = new URLRequest();
			var scale : Number = 1.0;
			var longLenOffset : Number;
			if (whrate >= RATE_16_9)
			{
				request.url = "Default-568h@2x.png";
				scale = shortLen/640;
				longLenOffset = (longLen - 1136*scale) /2;
			}
			else if (whrate >= RATE_3_2)
			{
				request.url = "Default@2x.png";
				scale =  shortLen/640;
				longLenOffset = (longLen - 960*scale) /2;
			}
			else if (whrate >= RATE_4_3)
			{
				request.url = "Default~ipad.png";
				scale = shortLen/768;
				longLenOffset = (longLen - 1024*scale) /2;
			}
			trace(request.url);
			// 显示比例保证短边顶满，长边可以显示不全，保证撑满屏幕
			picLoader.load(request);
			picLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onPicLoaded);
			picLoader.scaleX =picLoader.scaleY = scale;
			if (isLandscape)
			{
				picLoader.rotation = -90;
				picLoader.y+=shortLen;
				trace('picLoader.y: ' + (picLoader.y));
				picLoader.x += longLenOffset;
				trace('longLenOffset: ' + (longLenOffset));
				trace('picLoader.x: ' + (picLoader.x));
			}
			trace('scale: ' + (scale));
			addChild(picLoader);
		}

		private function onPicLoaded(event : Event) : void
		{
			mainLoader = new Loader();
			var request : URLRequest = new URLRequest();
			request.url = "main.swf";
			mainLoader.load(request);
			mainLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onMainLoaded);
		}

		private function onMainLoaded(event : Event) : void
		{
			addChild(mainLoader);
			removeChild(picLoader);
		}
	}
}
