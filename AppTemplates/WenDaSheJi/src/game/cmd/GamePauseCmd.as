package game.cmd
{
	import game.view.SceneEvent;
	import game.model.GameDataModel;

	import org.mousebomb.GameConf;
	import org.robotlegs.mvcs.Command;

	import flash.display.DisplayObject;

	/**
	 * @author Mousebomb
	 */
	public class GamePauseCmd extends Command
	{
		public function GamePauseCmd()
		{
		}

		[Inject]
		public var gameData : GameDataModel;
		[Inject]
		public var e : SceneEvent;

		override public function execute() : void
		{
			if (e.type == SceneEvent.SCENE_REQUEST_CONTINUE)
			{
				gameData.paused=false;
			}
			else if(e.type == SceneEvent.SCENE_REQUEST_PAUSE)
			{
				gameData.paused = true;
				var child : DisplayObject = new UIHoverMenu();
				contextView.addChild(child);
			}
		}
	}
}
