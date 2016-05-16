package
{
	import org.mousebomb.Localize;
	import org.mousebomb.GameConf;
	import org.mousebomb.Sfx;

	import flash.display.Sprite;
	import flash.events.MouseEvent;

	/**
	 * @author Mousebomb
	 */
	public class RUSureView
	{
		private var confirmUI : Sprite;
		private var confirmCb : Function;

		public function RUSureView(container : Sprite, confirmCb : Function)
		{
			this.confirmCb = confirmCb;
			confirmUI = new (Localize.getClass("ReplayConfirm"))();
			container.addChild(confirmUI);
			confirmUI['yes'].addEventListener(MouseEvent.CLICK, onYesClick);
			confirmUI['no'].addEventListener(MouseEvent.CLICK, onNoClick);
			confirmUI.x = GameConf.VISIBLE_SIZE_W/2;
			confirmUI.y = GameConf.VISIBLE_SIZE_H/2;
		}

		private function onNoClick(event : MouseEvent) : void
		{
			confirmUI.parent.removeChild(confirmUI);
			Sfx.other.gotoAndStop(1);
			Sfx.other.gotoAndStop("btn");
		}

		private function onYesClick(event : MouseEvent) : void
		{
			if(confirmCb!=null) confirmCb();
			confirmUI.parent.removeChild(confirmUI);
			Sfx.other.gotoAndStop(1);
			Sfx.other.gotoAndStop("btn");
		}
	}
}
