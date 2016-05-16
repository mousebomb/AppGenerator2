/**
 * Created by rhett on 14-7-19.
 */
package org.mousebomb.zhaocha.level
{
import com.aoaogame.sdk.adManager.MyAdManager;
import com.aoaogame.sdk.AoaoGameSDK;
import flash.display.DisplayObject;
import flash.events.MouseEvent;
import flash.geom.ColorTransform;
import flash.geom.Rectangle;

import org.mousebomb.GameConf;
import org.mousebomb.SoundMan;
import org.mousebomb.ui.Shelf;
import org.mousebomb.zhaocha.common.SceneEvent;

import org.robotlegs.mvcs.Mediator;

public class UILevelMediator extends Mediator
{
    public function UILevelMediator()
    {
        super();
    }

    [Inject]
    public var levelModel : LevelModel;
    private var shelf:Shelf;
    override public function onRegister():void
    {

        var ui : UILevel = viewComponent as UILevel;
		ui.moreBtn.visible = AoaoBridge.isMoreBtnVisible;
		ui.moreBtn.addEventListener(MouseEvent.CLICK, onMoreClick);

        shelf = new Shelf();
        var rect:Rectangle = new Rectangle(15,138,610,720);
        shelf.x = 15;
        shelf.y = 138;
        //
        var shelfAndPageBtnH :Number = GameConf.VISIBLE_SIZE_H - 100- shelf.y;
		var pageBtnH:Number = ui.nextBtn.height;
		var pageBtnOffsetY :Number = pageBtnH/2;
		var shelfH:Number  = shelfAndPageBtnH - pageBtnH-50;
		ui.prevBtn.y = ui.nextBtn.y = GameConf.VISIBLE_SIZE_H - 120 - pageBtnOffsetY;
        //
		var sample : DisplayObject = new LevelBtn();
		shelf.autoConfig(610, shelfH, sample.width, sample.height, 5, 6, LevelBtn, onAddLi);

        ui.addChild(shelf);
        //
        levelModel.initAllLevels();
        shelf.setList(levelModel.levels);
        //
        ui.prevBtn.addEventListener(MouseEvent.CLICK, onPrevBtn);
        ui.nextBtn.addEventListener(MouseEvent.CLICK, onNextBtn);
        //

        ui.backBtn.addEventListener(MouseEvent.CLICK, onBackClick);
	}

	private function onMoreClick(event : MouseEvent) : void 
	{
		AoaoBridge.gengDuo(contextView);
	}

    private function onBackClick(event : MouseEvent) : void
    {
        SoundMan.playSfx(SoundMan.BTN);
        dispatch(new SceneEvent(SceneEvent.SCENE_REPLACE, UIWelcome));
    }

    private function onNextBtn(event : MouseEvent) : void
    {
        SoundMan.playSfx(SoundMan.BTN);
        shelf.nextPage();
    }

    private function onPrevBtn(event : MouseEvent) : void
    {
        SoundMan.playSfx(SoundMan.BTN);
        shelf.prevPage();
    }

    private function onAddLi(li : LevelBtn, vo : LevelVO) : void
    {
        li.levelTf.text = vo.level.toString();
        li.levelTf.mouseEnabled = false;
        var colorTransform : ColorTransform = new ColorTransform();
        colorTransform.color = 0xaaaaaa;
//        if (vo.star < 3)
//        {
//            li.star3.transform.colorTransform = colorTransform;
//            if (vo.star < 2)
//            {
//                li.star2.transform.colorTransform = colorTransform;
//                if (vo.star < 1)
//                {
//                    li.star1.transform.colorTransform = colorTransform;
//                }
//            }
//        }
        // li.star1.alpha = vo.star>0 ? 1.0 : 0.5;
        // li.star2.alpha = vo.star>1 ? 1.0 : 0.5;
        // li.star3.alpha = vo.star>2 ? 1.0 : 0.5;
        if (vo.canPlay)
        {
            li.addEventListener(MouseEvent.MOUSE_UP, onLiUp);
        }
        else
        {
            li.alpha = 0.5;
        }
        li.vo = vo;
    }

    private function onLiUp(event : MouseEvent) : void
    {
        var li : LevelBtn = event.currentTarget as LevelBtn;
        var e:LevelSelectEvent = new LevelSelectEvent(LevelSelectEvent.LEVEL_SELECTED);
        e.selectedLevel = (li.vo as LevelVO).level;
        dispatch(e);
    }
}
}
