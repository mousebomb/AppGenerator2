package game.cmd
{
	import game.view.SceneEvent;

	import org.robotlegs.mvcs.Command;

	import flash.display.Sprite;

	/**
	 * @author Mousebomb
	 */
	public class SceneReplaceCmd extends Command
	{
		public function SceneReplaceCmd()
		{
		}

		[Inject]
		public var e : SceneEvent;

		override public function execute() : void
		{
			var view:Sprite = new e.presentView();
			(contextView as QnAofGeo).replaceScene(view);
		}
	}
}
