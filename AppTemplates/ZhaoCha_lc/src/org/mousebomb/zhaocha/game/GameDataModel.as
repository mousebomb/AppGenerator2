/**
 * Created by rhett on 14-7-19.
 */
package org.mousebomb.zhaocha.game
{
import flash.events.Event;

import org.robotlegs.mvcs.Actor;

public class GameDataModel extends Actor
{
    public function GameDataModel()
    {
        super();
    }


    public function gotoLevel(l:int):void
    {
        var e:GameEvent = new GameEvent(GameEvent.GAME_GOTO_LEVEL);
        e.level = l;
        _level = l;
        dispatch(e);
    }

    /**
     * 当前关卡 ，发现了一个
     */
    public function foundOne():void
    {
        _foundCount++;
        var e :GameEvent = new GameEvent(GameEvent.GAME_DIFFCOUNT_CHANGE);
        e.differenceCount = _differenceCount;
        e.foundCount = _foundCount;
        dispatch(e);

        //
        if(_foundCount >= _differenceCount)
        {
            var winE :GameEvent = new GameEvent(GameEvent.GAME_WIN);
			winE.level = _level;
            dispatch(winE);
        }
    }

    // 当前关卡总共多少个不同
    private var _differenceCount:int = 0;
    // 当前关已发现
    private var _foundCount:int = 0;
    // 当前关卡
    private var _level : int = 0;

    /**
     * 当前关卡总共多少个不同
     * @param count
     */
    public function differencesToFind(count:int):void
    {
        _differenceCount = count;
        _foundCount = 0;
        var e :GameEvent = new GameEvent(GameEvent.GAME_DIFFCOUNT_CHANGE);
        e.differenceCount = count;
        e.foundCount = 0;
        dispatch(e);
    }
}
}
