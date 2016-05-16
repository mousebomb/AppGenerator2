package fan
{
	import org.mousebomb.IFlyIn;
	import org.mousebomb.SoundMan;
	import org.mousebomb.interfaces.IDispose;

	import flash.display.Sprite;
	import flash.events.MouseEvent;

	/**
	 * @author rhett
	 */
	public class FFWelcome extends Sprite implements IDispose,IFlyIn
	{
		public function FFWelcome()
		{
			addChild(new UIWelcome());

			this.addEventListener(MouseEvent.CLICK, onClickAnywhere);
		}

		private function onClickAnywhere(event : MouseEvent) : void
		{
			SoundMan.playSfx(SoundMan.BTN);

			var levelModel : LevelModel = LevelModel.getInstance();
			levelModel.initAllLevels();
			if (levelModel.levelFinished < 1)
			{
				FanFanLe.instance.replaceScene(new FFGame());
			}
			else
			{
				FanFanLe.instance.replaceScene(new FFLevel());
			}
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
