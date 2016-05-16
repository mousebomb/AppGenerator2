package game.cmd {
	import game.service.TimuService;

	import org.robotlegs.mvcs.Command;

	/**
	 * @author Mousebomb
	 */
	public class StartupCmd extends Command
	{
		public function StartupCmd()
		{
		}

		[Inject]
		public var timuService : TimuService;

		override public function execute() : void
		{
			timuService.loadTimu();
		}
	}
}
