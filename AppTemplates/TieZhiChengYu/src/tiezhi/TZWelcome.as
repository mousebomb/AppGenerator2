package tiezhi
{
	import org.mousebomb.IFlyIn;
	import org.mousebomb.SoundMan;
	import org.mousebomb.interfaces.IDispose;

	import flash.display.Sprite;
	import flash.events.MouseEvent;

	/**
	 * @author rhett
	 */
	public class TZWelcome extends Sprite implements IDispose,IFlyIn
	{
		public function TZWelcome()
		{
			addChild(new UIWelcome());
			
			
			this.addEventListener(MouseEvent.CLICK, onClickAnywhere);
		}

		private function onClickAnywhere(event : MouseEvent) : void
		{
			SoundMan.playSfx(SoundMan.BTN);
			TieZhi.instance.replaceScene(new TZLevel());
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
