/**
 * Created by rhett on 14-7-19.
 */
package
{
import flash.display.DisplayObject;
import flash.display.Sprite;

import org.mousebomb.IFlyIn;
import org.mousebomb.SoundMan;
import org.mousebomb.interfaces.IDispose;
import org.mousebomb.zhaocha.GameContext;
import org.mousebomb.zhaocha.game.GameDataModel;

public class ZhaoCha extends AoaoGame
{
    private var _context:GameContext;
    public function ZhaoCha()
    {
        super();
    }

    override protected function start():void
    {
        super.start();
        _context = new GameContext(rootView);
        SoundMan.playBgm("bgm.mp3");
    }

}
}
