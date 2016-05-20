package org.mousebomb.tianse
{

	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import org.mousebomb.GameConf;
	import org.mousebomb.SoundMan;

	/**
	 * @author Mousebomb
	 */
	public class TSRUSureView
	{
		private var confirmUI : Sprite;
		private var confirmCb : Function;

		public function TSRUSureView(container : Sprite, confirmCb : Function)
		{
			this.confirmCb = confirmCb;
			confirmUI = new UITSReplayConfirm();
			container.addChild(confirmUI);
			confirmUI['yes'].addEventListener(MouseEvent.CLICK, onYesClick);
			confirmUI['no'].addEventListener(MouseEvent.CLICK, onNoClick);
			confirmUI.x = GameConf.VISIBLE_SIZE_W/2;
			confirmUI.y = GameConf.VISIBLE_SIZE_H/2;
		}

		private function onNoClick(event : MouseEvent) : void
		{
			confirmUI.parent.removeChild(confirmUI);
			SoundMan.playSfx(SoundMan.BTN);
		}

		private function onYesClick(event : MouseEvent) : void
		{
			if(confirmCb!=null) confirmCb();
			confirmUI.parent.removeChild(confirmUI);
			SoundMan.playSfx(SoundMan.BTN);
		}
	}
}
