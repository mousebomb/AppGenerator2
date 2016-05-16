/**
 * Created by rhett on 14-7-19.
 */
package org.mousebomb.zhaocha
{
import org.mousebomb.zhaocha.common.SceneEvent;
import org.mousebomb.zhaocha.common.SceneReplaceCmd;
import org.mousebomb.zhaocha.game.GameDataModel;
import org.robotlegs.mvcs.Command;

public class StartupCompleteCmd extends Command
{
    public function StartupCompleteCmd()
    {
        super();
    }


    override public function execute():void
    {
        commandMap.execute(SceneReplaceCmd,new SceneEvent(SceneEvent.SCENE_REPLACE, UIWelcome));
    }
}
}
