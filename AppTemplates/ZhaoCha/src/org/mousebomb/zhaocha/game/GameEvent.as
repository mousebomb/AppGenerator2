/**
 * Created by rhett on 14-7-19.
 */
package org.mousebomb.zhaocha.game
{
import flash.events.Event;

public class GameEvent extends Event
{
    // 切换到关卡
    public static const GAME_GOTO_LEVEL:String = "GAME_PLAY_LEVEL";

    public var level:int ;

    // 关卡不同之处数量
    public static const GAME_DIFFCOUNT_CHANGE:String = "GAME_DIFFCOUNT_CHANGE";
public var differenceCount:int;
    public var foundCount : int;


/**
 * 关卡过关
 */
    public static const GAME_WIN:String = "GAME_WIN";
/**
 * 游戏通关
 */
    public static const GAME_ALL_WIN:String = "GAME_ALL_WIN";

    public function GameEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
    {
        super(type, bubbles, cancelable);
    }
}
}
