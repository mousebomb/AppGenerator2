package fan
{
	import flash.events.TimerEvent;

	import org.mousebomb.GameConf;
	import org.mousebomb.IFlyIn;
	import org.mousebomb.SoundMan;
	import org.mousebomb.interfaces.IDispose;
	import org.mousebomb.ui.Shelf;
	import org.mousebomb.utils.FrameScript;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;

import com.greensock.TweenLite;
import com.greensock.easing.Back;

	/**
	 * @author rhett
	 */
	public class FFGame extends Sprite implements IDispose,IFlyIn
	{
		private var ui : UIGame;
		private var levelModel : LevelModel;
		private var shelf : Shelf;
		private const topSize : Number = 130;
		
//		private var timer : Timer ;
		private var bg : Scenes;

		[Embed(source="../../cards/bg.png")]
		private static const BgPng:Class;
		[Embed(source="../../cards/front.png")]
		private static const FrontPng:Class;
		[Embed(source="../../cards/back.png")]
		private static const BackPng:Class;

		public function FFGame()
		{
			//
//			trace(new BgPng());
			Card.bgBmd = new BgPng().bitmapData;
			Card.frontBmd = new FrontPng().bitmapData;
			Card.backBmd = new BackPng().bitmapData;
			//
			ui = new UIGame();
			ui.bottom.y = GameConf.VISIBLE_SIZE_H;
			ui.nextBtn.visible = false;
			ui.nextBtn.addEventListener(MouseEvent.CLICK, onNextBtnClick);
			ui.timeTf.text = "";
			ui.win.visible = false;
			addChild(ui);
			ui.backBtn.addEventListener(MouseEvent.CLICK, onBackClick);
			//
//			timer = new Timer(200);
//			timer.addEventListener(TimerEvent.TIMER, onTimer);
			//
			levelModel = LevelModel.getInstance();
			trace("FFGame/FFGame()",levelModel.level);
			//
			makeShelf();
			//
			changeLevel(levelModel.level);
		}

		private var passedTime : int=0;
		//翻牌次数
		private var fanTimes : int = 0;

//		private function onTimer(event : TimerEvent) : void
//		{
//			passedTime+= timer.delay;
//			var sec : int = passedTime / 1000;
//			var t : int = (sec % 60 );
//			var strSec : String = t < 10 ? "0" + t. toString() : t.toString();
//			var strMin : String = int(sec / 60). toString();
//			ui.timeTf.text = strMin + ":" + strSec;
//		}

		private function onNextBtnClick(event : MouseEvent) : void
		{
			SoundMan.playSfx(SoundMan.BTN);
			if ( (levelModel.levelCount > levelModel.level ) )
			{
				levelModel.level += 1;
				changeLevel(levelModel.level);
			}
		}

		private static var sampleW : Number;
		private static var sampleH : Number;

		private function makeShelf() : void
		{
			bg = new Scenes();
			bg.gotoAndStop(1);
			addChildAt(bg, 0);
			//
			sampleW = Card.bgBmd.width;
			sampleH = Card.bgBmd.height;
			shelf = new Shelf();
			setShelfSize(4, 3);
			addChildAt(shelf, 1);
		}

		private function setShelfSize(cols : int, rows : int) : void
		{
			shelf.config(sampleW,sampleH,cols*rows,cols,Card,onAddCard);
			/** shelf列出后实际需要占有尺寸 */
			var shelfW : Number = sampleW * cols;
			var shelfH : Number = sampleH * rows;
			/** 实际允许占有尺寸 */
			var screenH:Number = GameConf.VISIBLE_SIZE_H_MINUS_AD - topSize;
			var screenW:Number = GameConf.DESIGN_SIZE_W;
			/**  */
			var scW :Number = screenW / shelfW;
			var scH :Number = screenH / shelfH;
			var scale :Number = scW < scH?scW:scH;
			shelf.scaleX = shelf.scaleY = scale;
			shelf.x = (sampleW/2 )*scale + (screenW - shelfW*scale)/2;
			shelf.y = (sampleH /2 )*scale+topSize + (screenH - shelfH*scale)/2 ;
			// trace("ShelfRect = ", shelfRect , "for",cols+"x"+rows);
//			CONFIG::DEBUG
//			{
//				shelf.graphics.lineStyle(3, 0xff0000);
//				shelf.graphics.drawRect(0, 0, shelfRect.width, shelfRect.height);
//				shelf.graphics.endFill();
//			}
		}

		public function changeLevel(level : int) : void
		{
			var levelConf :Array = levelModel.getLevelConf(level);
			//
			puzzleLeft = levelConf[0]* levelConf[1] /2;
			setShelfSize(levelConf[0],levelConf[1]);
			trace("FFGame/changeLevel("+level+")",levelConf);
			passedTime = 0;
			tmpSelectedCard = null;
			isAnimationPlaying = false;
			// ui
			ui.nextBtn.visible = false;
			ui.win.visible = false;
//			timer.reset();
//			timer.start();
fanTimes =0;
ui.timeTf.text ="0";
			//
			var listData : Array = getCardPic(puzzleLeft , levelConf[2]) ;
			listData.sort(randomSort);
			shelf.setList(listData);
			//
			bg.gotoAndStop(level);
			//
			if(!CONFIG::DEBUG)
			{AoaoBridge.banner(this);}
		}

		/** 本关的不同图标种量 */
		// 获得 成对的pic count=几对
		private function getCardPic(count : int,levelPicNum:int ) : Array
		{
			if(levelPicNum > LevelModel.PIC_NUM){throw new Error("图标种类不够用");}
			var arr : Array = [];
			var start : int = int(Math.random() * levelPicNum);
			var nextI : int;
			for (var i : int = 0; i < count; i++)
			{
				nextI = (start + i ) % levelPicNum + 1;
				// 插入一对
				arr.push(nextI);
				arr.push(nextI);
			}
			return arr;
		}

		private function onBackClick(event : MouseEvent) : void
		{
			SoundMan.playSfx(SoundMan.BTN);
			AoaoBridge.interstitial(this);
			FanFanLe.instance.replaceScene(new FFLevel());
		}

		private function randomSort(elementA : Object, elementB : Object) : int
		{
			return int(Math.random() * 3) - 1;
		}

		private function onAddCard(li : Card, vo : int) : void
		{
			//
			li.id = vo;
			li.flip = 1;
			li.addEventListener(MouseEvent.MOUSE_DOWN, onCardClick);
		}

		// 翻卡片动画播完
		private function onCardFinishFan(li : Card) : void
		{
			isAnimationPlaying = false;
			// 检查是否一样
			//
			if (tmpSelectedCard == null)
			{
				// 如果没有翻过
				tmpSelectedCard = li;
			}
			else
			{
				// 翻过了
				if (tmpSelectedCard.id == li.id)
				{
					SoundMan.playSfx(SoundMan.RIGHT);
					li.right();
					tmpSelectedCard.right();
					checkLevelWin();
				}
				else
				{
					tmpSelectedCard.gai();
					li.gai();
					li.mouseChildren = li.mouseEnabled = tmpSelectedCard.mouseChildren = tmpSelectedCard.mouseEnabled = true;
					SoundMan.playSfx(SoundMan.WRONG);
				}
				tmpSelectedCard = null;
			}
		}

		private var puzzleLeft : int = 3;

		// 检查是否满足过关
		private function checkLevelWin() : void
		{
			if (--puzzleLeft == 0)
			{
				SoundMan.playSfx(SoundMan.PRIZE);

				ui.win.timeTf.text = ui.timeTf.text ;
//				timer.reset();
fanTimes =0;
                playWinAnimation (levelModel.level < levelModel.levelCount);
				levelModel.saveLevel(levelModel.level, 1);
				AoaoBridge.interstitial(this);
			}
		}

    private function playWinAnimation( showNextBtn :Boolean ):void
    {
        ui.win.visible = true;
        ui.win.scaleX = ui.win.scaleY = 0.01;

        TweenLite.to(ui.win,1,{scaleX:1,scaleY:1,ease:Back.easeOut});
        if(!showNextBtn) return;
        setTimeout(function():void
        {
            ui.nextBtn.visible = true;
            var oldY:Number = ui.nextBtn.y;
            ui.nextBtn.y -=100;
            TweenLite.to(ui.nextBtn,.8,{y:oldY,ease:Back.easeOut});
        },1200 );
    }

		private var isAnimationPlaying : Boolean = false;
		// 之前选的卡
		private var tmpSelectedCard : Card;

		// 点击一张卡
		private function onCardClick(event : MouseEvent) : void
		{
			SoundMan.playSfx(SoundMan.FINISH);
			var li : Card = event.currentTarget as Card;
			li.mouseEnabled = false;
			li.mouseChildren = false;
			li.fan(onCardFinishFan);
			isAnimationPlaying = true;
			//
			fanTimes ++;
			ui.timeTf.text = fanTimes.toString();
		}

		public function dispose() : void
		{
		}

		public function flyIn() : void
		{
		}
	}
}
