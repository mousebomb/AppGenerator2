package game.cmd
{
	import game.model.GameDataModel;
	import org.robotlegs.mvcs.Command;

	/**
	 * @author Mousebomb
	 */
	public class GameReplayCmd extends Command
	{
		public function GameReplayCmd()
		{
		}

[Inject]
public var gameData:GameDataModel;
		override public function execute() : void
		{
			
			gameData.startLevel();
			
		}

	}
}
