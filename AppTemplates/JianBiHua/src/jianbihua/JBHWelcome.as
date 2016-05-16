package jianbihua {
	import org.mousebomb.IFlyIn;
	import org.mousebomb.SoundMan;
	import org.mousebomb.interfaces.IDispose;

	import flash.display.Sprite;
	import flash.events.MouseEvent;

	/**
	 * @author rhett
	 */
	public class JBHWelcome extends Sprite implements IDispose,IFlyIn
	{
		public function JBHWelcome()
		{
			addChild(new UIWelcome());
			
			
			this.addEventListener(MouseEvent.CLICK, onClickAnywhere);
		}

		private function onClickAnywhere(event : MouseEvent) : void
		{
			SoundMan.playSfx(SoundMan.BTN);
			JianBiHua.instance.replaceScene(new JBHLevel());
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
