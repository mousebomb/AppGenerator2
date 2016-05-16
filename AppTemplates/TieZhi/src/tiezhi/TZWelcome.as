package tiezhi
{
	import org.mousebomb.interfaces.IDispose;
	import org.mousebomb.IFlyIn;
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
