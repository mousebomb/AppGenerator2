/**
 * Created by rhett on 14-7-19.
 */
package org.mousebomb.zhaocha.level
{
import flash.events.Event;

public class LevelSelectEvent extends Event
{

    // 选中关卡
    public static const LEVEL_SELECTED:String = "LEVEL_SELECTED";
    //
    public var selectedLevel:int;
    public function LevelSelectEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
    {
        super(type, bubbles, cancelable);
    }
}
}
