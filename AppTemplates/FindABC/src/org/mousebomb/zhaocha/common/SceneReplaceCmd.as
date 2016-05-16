package org.mousebomb.zhaocha.common
{
import flash.display.DisplayObject;

import org.mousebomb.IFlyIn;
import org.mousebomb.interfaces.IDispose;
import org.robotlegs.mvcs.Command;

import flash.display.Sprite;

/**
 * @author Mousebomb
 */
public class SceneReplaceCmd extends Command
{
    public function SceneReplaceCmd()
    {
    }

    [Inject]
    public var e:SceneEvent;


    static private var _scene:DisplayObject;

    override public function execute():void
    {
        var view:Sprite = new e.presentView();
        if (_scene)
        {
            contextView.removeChild(_scene);
        }
        _scene = view;

        contextView.addChild(_scene);
    }
}
}
