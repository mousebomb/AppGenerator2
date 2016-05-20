/**
 * Created by rhett on 16/5/17.
 */
package yizhidaquan
{

	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import org.mousebomb.IFlyIn;
	import org.mousebomb.SoundMan;
	import org.mousebomb.interfaces.IDispose;
	import org.mousebomb.wenda.WDLevelModel;

	public class YZWelcome extends Sprite implements IDispose,IFlyIn
	{
		public function YZWelcome()
		{

			addChild(new UIWelcome());
			WDLevelModel.getInstance();

			this.addEventListener(MouseEvent.CLICK, onClickAnywhere);
		}

		private function onClickAnywhere(event : MouseEvent) : void
		{
			SoundMan.playSfx(SoundMan.BTN);
			YiZhiDaQuan.instance.replaceScene(new YZSelectGame());
		}

		public function dispose() : void
		{
			removeEventListener(MouseEvent.CLICK, onClickAnywhere);
		}

		public function flyIn() : void
		{
		}
	}
}
