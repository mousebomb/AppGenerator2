/**
 * Created by rhett on 16/5/17.
 */
package yizhidaquan
{

	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import org.mousebomb.IFlyIn;
	import org.mousebomb.SoundMan;
	import org.mousebomb.fan.FFLevel;
	import org.mousebomb.interfaces.IDispose;
	import org.mousebomb.jianbihua.JBHLevel;
	import org.mousebomb.pin9gong.P9Level;
	import org.mousebomb.tianse.TSLevel;

	import org.mousebomb.tiezhi.TZLevel;
	import org.mousebomb.wenda.WDLevel;

	public class YZSelectGame extends Sprite implements IDispose,IFlyIn
	{
		private var ui :UISelectGame;
		public function YZSelectGame()
		{

			ui = new UISelectGame();
			addChild(ui);

			ui.backBtn.addEventListener(MouseEvent.CLICK, onJianbihuaClick);
			ui.jianbihuaBtn.addEventListener(MouseEvent.CLICK, onJianbihuaClick);
			ui.tianseBtn.addEventListener(MouseEvent.CLICK, onJianbihuaClick);
			ui.tiezhiBtn.addEventListener(MouseEvent.CLICK, onJianbihuaClick);
			ui.fanBtn.addEventListener(MouseEvent.CLICK, onJianbihuaClick);
			ui.pin9Btn.addEventListener(MouseEvent.CLICK, onJianbihuaClick);

		}

		private function onJianbihuaClick( event:MouseEvent ):void
		{
			SoundMan.playSfx(SoundMan.BTN);
			switch (event.currentTarget)
			{

				case ui.backBtn:
					YiZhiDaQuan.instance.replaceScene(new YZWelcome());
					break;

				case ui.jianbihuaBtn:
					YiZhiDaQuan.instance.replaceScene(new JBHLevel());
					break;
				case ui.tianseBtn:
					YiZhiDaQuan.instance.replaceScene(new TSLevel());
					break;
				case ui.tiezhiBtn:
					YiZhiDaQuan.instance.replaceScene(new TZLevel());
					break;
				case ui.fanBtn:
					YiZhiDaQuan.instance.replaceScene(new FFLevel());
					break;
				case ui.pin9Btn:
					YiZhiDaQuan.instance.replaceScene(new P9Level());
					break;
			}
		}

		public function dispose() : void
		{
			ui.backBtn.removeEventListener(MouseEvent.CLICK, onJianbihuaClick);
			ui.jianbihuaBtn.removeEventListener(MouseEvent.CLICK, onJianbihuaClick);
			ui.tianseBtn.removeEventListener(MouseEvent.CLICK, onJianbihuaClick);
			ui.tiezhiBtn.removeEventListener(MouseEvent.CLICK, onJianbihuaClick);
			ui.fanBtn.removeEventListener(MouseEvent.CLICK, onJianbihuaClick);
			ui.pin9Btn.removeEventListener(MouseEvent.CLICK, onJianbihuaClick);
		}

		public function flyIn() : void
		{
		}
	}
}
