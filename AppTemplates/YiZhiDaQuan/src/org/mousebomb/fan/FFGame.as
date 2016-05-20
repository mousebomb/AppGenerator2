package org.mousebomb.fan
{

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;

	import gs.TweenLite;
	import gs.easing.Back;

	import org.mousebomb.GameConf;
	import org.mousebomb.IFlyIn;
	import org.mousebomb.SoundMan;
	import org.mousebomb.interfaces.IDispose;
	import org.mousebomb.ui.Shelf;
	import org.mousebomb.utils.FrameScript;

	import yizhidaquan.YiZhiDaQuan;

	/**
	 * @author rhett
	 */
	public class FFGame extends Sprite implements IDispose,IFlyIn
	{
		private var ui : UIFFGame;
		private var levelModel : FFLevelModel;
		private var shelf : Shelf;
		private var shelfRect : Rectangle;
		// 4 ,3 ,2
		private const marginH : Array = [0, 0, 150, 15, 8];
		// 2 , 3
		private const marginV : Array = [0, 0, 120, 10];
		private const topSize : Number = 130;
		
//		private var timer : Timer ;

		public function FFGame()
		{
			//
			ui = new UIFFGame();
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
			levelModel = FFLevelModel.getInstance();
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
			ui.bg.gotoAndStop(1);
			//
			var sample : Card = new Card();
			sampleW = sample.width;
			sampleH = sample.height;
			shelf = new Shelf();
			setShelfSize(4, 3);
			ui.addChildAt(shelf, 1);
		}

		private function setShelfSize(cols : int, rows : int) : void
		{
			shelfRect = new Rectangle(marginH[cols], marginV[rows] + topSize, GameConf.DESIGN_SIZE_W - marginH[cols] * 2, GameConf.VISIBLE_SIZE_H_MINUS_AD - marginV[rows] * 2 - topSize);
			shelf.autoConfig(shelfRect.width, shelfRect.height, sampleW, sampleH, cols, rows, Card, onAddCard);
trace("FFGame/setShelfSize()",shelfRect , "=" , GameConf.VISIBLE_SIZE_H_MINUS_AD , marginV[rows] * 2 , topSize);
			//
			switch(cols )
			{
				case 2:
					shelf.scaleX = shelf.scaleY = 1.2;
					shelf.x = shelfRect.x - (shelfRect.width * .1);
					shelf.y = shelfRect.y - (shelfRect.height * .1);
					break;
				// case 3:
				// shelf.scaleX = shelf.scaleY = 1.2;
				// shelf.x = shelfRect.x - shelfRect.width * 0.1;
				// shelf.y = shelfRect.y - shelfRect.height * 0.1;
				// break;
				default:
					shelf.scaleX = shelf.scaleY = 1;
					shelf.x = shelfRect.x;
					shelf.y = shelfRect.y;
					break;
			}
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
			//
			if (level <= 2)
			{
				puzzleLeft = 2;
				setShelfSize(2, 2);
			}
			else if (level <= 4)
			{
				puzzleLeft = 3;
				setShelfSize(3, 2);
			}
			else if (level <= 8)
			{
				puzzleLeft = 4;
				setShelfSize(4, 2);
			}
			else
			{
				puzzleLeft = 6;
				setShelfSize(4, 3);
			}
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
			var listData : Array = getCardPic(puzzleLeft) ;
			listData.sort(randomSort);
			shelf.setList(listData);
			//
			ui.bg.gotoAndStop(level);
			//
			AoaoBridge.banner(YiZhiDaQuan.instance);
		}

		// 获得 成对的pic
		private function getCardPic(count : int) : Array
		{
			var arr : Array = [];
			var start : int = int(Math.random() * GameConf.TS_PIC_NUM);
			var nextI : int;
			for (var i : int = 0; i < count; i++)
			{
				nextI = (start + i ) % GameConf.TS_PIC_NUM + 1;
				// 插入一对
				arr.push(nextI);
				arr.push(nextI);
			}
			return arr;
		}

		private function onBackClick(event : MouseEvent) : void
		{
			SoundMan.playSfx(SoundMan.BTN);
			AoaoBridge.interstitial(YiZhiDaQuan.instance);
			YiZhiDaQuan.instance.replaceScene(new FFLevel());
		}

		private function randomSort(elementA : Object, elementB : Object) : int
		{
			return int(Math.random() * 3) - 1;
		}

		private function onAddCard(li : Card, vo : int) : void
		{
			//
			li.id = vo;
			li.stop();
			li.addEventListener(MouseEvent.MOUSE_DOWN, onCardClick);
			li.addFrameScript(li.totalFrames-1, li.stop);
			var fs : FrameScript = new FrameScript();
			fs.init(li);
			fs.addFrameCallback("open", function() : void
			{
				onCardFinishFan(li);
			});
			fs.addFrameCallback("openEnd", function() : void
			{
				li.gotoAndStop(1);
			});
			li.fs = fs;
			//
			var clazz : Class = getDefinitionByName("Pic" + vo) as Class;
			var pic : DisplayObject = new clazz();
			var sx : Number = (sampleW-8) / pic.width ;
			var sy : Number = (sampleH-8) / pic.height ;
			var scale : Number = sx < sy ? sx : sy;
			pic.scaleX = pic.scaleY = scale;
			li.front.addChild(pic);
		}

		// 翻卡片动画播完
		private function onCardFinishFan(li : Card) : void
		{
			isAnimationPlaying = false;
			// 检查是否一样
			li.stop()  ;
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
					li.gotoAndPlay("right");
					tmpSelectedCard.gotoAndPlay("right");
					checkLevelWin();
				}
				else
				{
					tmpSelectedCard.play();
					li.play();
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

				AoaoBridge.interstitial(YiZhiDaQuan.instance);
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
			li.gotoAndPlay(2);
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
