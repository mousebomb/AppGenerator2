package game.view
{
	import org.mousebomb.GameConf;

	import flash.display.Sprite;

	/**
	 * @author Mousebomb
	 */
	public class BlackBoard extends Sprite
	{
		private function init() : void
		{
			this.graphics.beginFill(0x0, 0.5);
			this.graphics.drawRect(0, 0, GameConf.VISIBLE_SIZE_W, GameConf.VISIBLE_SIZE_H);
			this.graphics.endFill();
		}

		private static var _instance : BlackBoard;

		public static function getInstance() : BlackBoard
		{
			if (_instance == null)
				_instance = new BlackBoard();
			return _instance;
		}

		public function BlackBoard()
		{
			if (_instance != null)
				throw new Error('singleton');

			init();
		}

		public function remove() : void
		{
			if (parent) parent.removeChild(this);
		}
	}
}
