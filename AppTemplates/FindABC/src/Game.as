/**
 * Created by rhett on 14-7-19.
 */
package {
	import org.mousebomb.SoundMan;
	import org.mousebomb.zhaocha.GameContext;

	public class Game extends AoaoGame {
		private var _context : GameContext;

		public function Game() {
			super();
		}

		override protected function start() : void {
			super.start();
			_context = new GameContext(rootView);
			SoundMan.playBgm("bgm.mp3");
		}
	}
}
