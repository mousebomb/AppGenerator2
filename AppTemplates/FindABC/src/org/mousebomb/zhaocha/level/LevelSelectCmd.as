/**
 * Created by rhett on 14-7-19.
 */
package org.mousebomb.zhaocha.level
{
import org.mousebomb.zhaocha.common.SceneEvent;
import org.mousebomb.zhaocha.game.*;
import org.robotlegs.mvcs.Command;

public class LevelSelectCmd extends Command
{
    public function LevelSelectCmd()
    {
        super();
    }

    [Inject]
    public var e : LevelSelectEvent;


    [Inject]
    public var gameDataModel:GameDataModel;
    override public function execute():void
    {
        dispatch(new SceneEvent(SceneEvent.SCENE_REPLACE, UIGame));
        gameDataModel.gotoLevel( e.selectedLevel);
    }
}
}
