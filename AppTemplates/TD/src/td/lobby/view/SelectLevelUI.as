/**
 * Created by rhett on 15/1/1.
 */
package td.lobby.view {
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

	import td.battlefield.view.ShelfS;
	import td.lobby.model.PlayerRecordModel;
	import td.lobby.model.vo.LevelVO;

	import com.aoaogame.sdk.adManager.MyAdManager;

	import org.mousebomb.GameConf;
	import org.mousebomb.SoundMan;

	public class SelectLevelUI extends Sprite
	{
		private var bg:Image;

		private var shelf:ShelfS;

		private var moreBtn:Button;
		private var prevBtn:Button;
		private var nextBtn:Button;

		public function SelectLevelUI()
		{
			bg = new Image( TDGame.assetsMan.getTexture( "SelectLevelBG" ) );
			addChild( bg );
			if( AoaoBridge.isMoreBtnVisible )
			{
				moreBtn = new Button( TDGame.assetsMan.getTexture( "MainScene_moreBtn" ) );
				moreBtn.alignPivot( HAlign.RIGHT, VAlign.TOP );
				moreBtn.x = GameConf.VISIBLE_SIZE_W - 10;
				moreBtn.addEventListener( Event.TRIGGERED, onMoreClick );
				addChild( moreBtn );
			}

			var liBgT:Texture = TDGame.assetsMan.getTexture( "SelectmapUI_border" );
			shelf = new ShelfS();
			shelf.autoConfig( 502, 542, liBgT.width, liBgT.height, 3, 2, LevelLi, liVoGlue );
			addChild( shelf );
			shelf.x = 128;
			shelf.y = 212;
			//
			prevBtn = new Button( TDGame.assetsMan.getTexture( "SelectLevelUI_prev" ) );
			nextBtn = new Button( TDGame.assetsMan.getTexture( "SelectLevelUI_next" ) );
			prevBtn.alignPivot();
			nextBtn.alignPivot();
			prevBtn.x = 268;
			nextBtn.x = 504;
			prevBtn.y = nextBtn.y = 812;
			addChild( prevBtn );
			addChild( nextBtn );
			prevBtn.addEventListener( Event.TRIGGERED, onPageClick );
			nextBtn.addEventListener( Event.TRIGGERED, onPageClick );
		}

		private function onPageClick( event:Event ):void
		{
			switch(event.currentTarget )
			{
				case prevBtn : shelf.prevPage();break;
				case nextBtn : shelf.nextPage();break;
			}
			SoundMan.playSfx(SoundMan.BTN);
		}

		private function onMoreClick( event:Event ):void
		{
			AoaoBridge.gengDuo(TDGame.instance);
		}

		private function liVoGlue( li:LevelLi, level:LevelVO ):void
		{
			li.setIndex( level.level );
			li.setStar( level.star );
			li.enabled = level.canPlay;
		}

		public function validate():void
		{
			PlayerRecordModel.getInstance().initAllLevels();
			shelf.setList( PlayerRecordModel.getInstance().levels );
		}
	}
}

import starling.utils.VAlign;
import starling.utils.HAlign;
import starling.display.Button;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.text.TextField;
import starling.textures.Texture;

import td.NotifyConst;

import org.mousebomb.SoundMan;
import org.mousebomb.framework.GlobalFacade;

class LevelLi extends Sprite
{

	private var levelTf:TextField;
	private var liBg:Image;
	private var btn:Button;

	private static var btnArea:Texture;
	private static var btnAreaGrey:Texture;


	public function LevelLi():void
	{
		var liBgT:Texture = TDGame.assetsMan.getTexture( "SelectmapUI_border" );
		liBg = new Image( liBgT );
		addChild( liBg );
		levelTf = new TextField( 100, 78, "1", "LevelLiNum", 62, 0xffffff );
		levelTf.x = liBg.width / 2 - 50;
		levelTf.y = liBg.height / 2 - 60;
		levelTf.touchable=false;
		addChild( levelTf );

		if( btnArea == null )
		{
			btnArea = Texture.empty( liBgT.width, liBgT.height );
			btnAreaGrey = Texture.fromColor( liBgT.width, liBgT.height, 0x99000000 );
			//		if( btnArea == null ) btnArea = Texture.fromColor(liBgT.width, liBgT.height ,0xffff0000);//
		}
		btn = new Button( btnArea, "", null, null, btnAreaGrey );
		this.addChild( btn );
		btn.addEventListener( Event.TRIGGERED, onTriggered );
	}

	private function onTriggered( event:Event ):void
	{
		GlobalFacade.sendNotify( NotifyConst.UI_SELECTLEVEL_LI_CLICK, this, _level );
		SoundMan.playSfx(SoundMan.BTN);
	}

	private var levelThumb:Image;
	private var _level:int;

	public function setIndex( level:int ):void
	{
		levelTf.text = level.toString();
		_level = level;
		var t:Texture = TDGame.assetsMan.getTexture( "L" + level );
		if( levelThumb )
		{
			levelThumb.texture = t;
		} else
		{
			levelThumb = new Image( t );
			addChildAt( levelThumb, 0 );
		}
		levelThumb.setSize( liBg.width, liBg.height );
	}

	public function set enabled( v:Boolean ):void
	{
		btn.enabled = v;
	}


	private var starImg:Image;

	public function setStar( star:int ):void
	{
		var starT:Texture = TDGame.assetsMan.getTexture( "SelectmapUI_star"+star );
		starImg = new Image(starT);
		starImg.alignPivot(HAlign.CENTER,VAlign.TOP);
		starImg.x = liBg.width / 2;
		starImg.y = 145;
		starImg.touchable=false;
		addChild(starImg);
	}
}