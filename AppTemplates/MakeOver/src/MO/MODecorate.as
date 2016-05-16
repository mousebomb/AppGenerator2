/**
 * Created by rhett on 15/7/12.
 */
package MO
{

import com.aoaogame.sdk.adManager.MyAdManager;
import com.greensock.TweenLite;

import flash.display.DisplayObject;
import flash.display.MovieClip;

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.utils.setTimeout;

import org.mousebomb.GameConf;
import org.mousebomb.SoundMan;

import org.mousebomb.interfaces.IDispose;

public class MODecorate extends Sprite implements IDispose
{

    public var ui:P2_Decorate;

    public function MODecorate()
    {
        super();
        ui = new P2_Decorate();
        addChild( ui );
        ui.moreBtn.visible = AoaoBridge.isMoreBtnVisible;
        ui.moreBtn.addEventListener( MouseEvent.CLICK, onMoreClick );
        //
        ui.showBtn.addEventListener( MouseEvent.CLICK, onShowClick );
        ui.saveBtn.addEventListener( MouseEvent.CLICK, onSaveClick );
        //
        ui.replayBtn.addEventListener(MouseEvent.CLICK, onReplayClick);
        decorate();
    }

    private function onReplayClick( event:MouseEvent ):void
    {
        SoundMan.playSfx(SoundMan.BTN);
        Game.instance.replaceScene( new MOWelcome());
    }

    private function onSaveClick( event:MouseEvent ):void
    {
        SoundMan.playSfx(SoundMan.BTN);
        ui.moreBtn.visible=ui.replayBtn.visible = false;
        ui.saveBtn.visible=false;
        AoaoBridge.saveScreen( GameConf.DESIGN_SIZE_W, GameConf.DESIGN_SIZE_H, ui )
        ui.replayBtn.visible = true;
        ui.moreBtn.visible= AoaoBridge.isMoreBtnVisible;
    }

    private function onShowClick( event:MouseEvent ):void
    {
        SoundMan.playSfx(SoundMan.PRIZE);
        show();
    }

    private function onMoreClick( event:MouseEvent ):void
    {
        SoundMan.playSfx(SoundMan.BTN);
        AoaoBridge.gengDuo(this);
    }


    private function decorate():void
    {
        ui.saveBtn.visible = ui.replayBtn.visible = false;
        ui.showBtn.visible = true;
        var i:int = 1;
        while( true )
        {
            var btnChild:DisplayObject = ui.getChildByName( "b" + i );
            var pChild:MovieClip = ui.getChildByName( "p" + i ) as MovieClip;
            if( btnChild == null )
                break;
            btnChild.addEventListener( MouseEvent.CLICK, onBClick );
            pChild.stop();
            i++;
        }
    }

    private function onBClick( event:MouseEvent ):void
    {
        SoundMan.playSfx(SoundMan.BTN);
        var btnId:String = (event.currentTarget as DisplayObject).name.substr( 1 );
        var p:MovieClip = ui.getChildByName( "p" + btnId ) as MovieClip;
        if( p.currentFrame >= p.totalFrames )
            p.gotoAndStop( 1 ); else p.nextFrame();
    }

    private function show():void
    {
        if( !CONFIG::DESKTOP )
        {
            AoaoBridge.interstitial(this);
        }
        ui.showBtn.visible = false;
        var i:int = 1;
        while( true )
        {
            var btnChild:DisplayObject = ui.getChildByName( "b" + i );
            if( btnChild == null )
                break;
            btnChild.visible=false;
            i++;
        }
        setTimeout( function ():void {
            ui.saveBtn.visible = ui.replayBtn.visible = true;
        } , 1500);
    }

    public function dispose():void
    {
    }
}
}
