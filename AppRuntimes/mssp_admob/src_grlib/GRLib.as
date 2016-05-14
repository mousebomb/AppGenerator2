/**
 * Created by rhett on 16/5/13.
 */
package
{

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;

	/**
	 * 此类提供各种功能，比如广告展示，更多广告，统计，通知等
	 */
	public class GRLib extends Sprite
	{
		public function GRLib()
		{
			this.addEventListener( Event.ADDED_TO_STAGE, onStage );
		}

		private function onStage( event:Event ):void
		{
			bindRoot(stage.root);
		}

		/**
		 * 绑定root 监听事件调用
		 * @param r
		 */
		public function bindRoot( r:IEventDispatcher )
		{
			r.addEventListener( "GENG_DUO", onGengDuo );
			r.addEventListener( "BANNER", onBanner );
			r.addEventListener( "INTERSTITIAL", onInterstitial );
		}

		private function onInterstitial( event:Event ):void
		{
			trace("GRLib/onInterstitial()");
			//			if(!CONFIG::DESKTOP)
			//				adsMogo.runInterstitial();
		}

		private function onBanner( event:Event ):void
		{
			trace("GRLib/onBanner()");
			//			if(!CONFIG::DESKTOP)
			//				adsMogo.runBanner();
		}

		private function onGengDuo( event:Event ):void
		{
			trace("GRLib/onGengDuo()");
			//			MyAdManager.showAd( MyAdManager.LEFT_DOWN );
		}

	}
}
