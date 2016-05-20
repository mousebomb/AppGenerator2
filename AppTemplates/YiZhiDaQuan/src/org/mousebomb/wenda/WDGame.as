/**
 * Created by rhett on 16/5/18.
 */
package org.mousebomb.wenda
{

	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import org.mousebomb.IFlyIn;
	import org.mousebomb.interfaces.IDispose;

	import yizhidaquan.YiZhiDaQuan;

	public class WDGame extends Sprite implements IDispose,IFlyIn
	{
		private var ui :UIWDGameScene;
		public function WDGame()
		{
			super();
ui = new UIWDGameScene();
			addChild(ui);
			ui.backBtn.addEventListener( MouseEvent.CLICK, onBackClick );
			ui.aBtn1.addEventListener( MouseEvent.CLICK, onAnsClick );
			ui.aBtn2.addEventListener( MouseEvent.CLICK, onAnsClick );

			ui.lianshengTf.text = datiModel.lianSheng.toString();
			ui.jinbiTf.text = datiModel.jinbi.toString();
			ui.liansheng2Tf.text = datiModel.jinbi2.toString();
			//
			WDLevelModel.timuModel
		}

		private function onBackClick( event:MouseEvent ):void
		{
			YiZhiDaQuan.instance.replaceScene(new WDLevel());
		}

		public function dispose():void
		{
		}

		public function flyIn():void
		{
		}
	}
}
