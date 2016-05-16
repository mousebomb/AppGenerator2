package org.mousebomb.zhaocha.game
{
	import org.robotlegs.mvcs.Command;

	/**
	 * @author rhett
	 */
	public class GameAllWinCmd extends Command
	{
		public function GameAllWinCmd()
		{
		}
		
		override public function execute() : void
		{
			contextView.addChild(new UIGameWin());
		}
	}
}
