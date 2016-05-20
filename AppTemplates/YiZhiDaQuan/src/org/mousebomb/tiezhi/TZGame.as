package org.mousebomb.tiezhi
{

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;

	import gs.TweenLite;
	import gs.easing.Back;

	import org.mousebomb.GameConf;
	import org.mousebomb.IFlyIn;
	import org.mousebomb.Math.MousebombMath;
	import org.mousebomb.SoundMan;
	import org.mousebomb.interfaces.IDispose;
	import org.mousebomb.ui.Shelf;

	import yizhidaquan.YiZhiDaQuan;

	/**
	 * @author rhett
	 */
	public class TZGame extends Sprite implements IDispose,IFlyIn
	{
		private var ui : UITZGame;
		private var levelModel : TZLevelModel;
		private var holeShelf : Shelf;
		private var choiceContainer : Sprite = new Sprite();
		private static var SELECTION_X : Array = [0, 180, 360];
		// hole 的 index  index :Pic几 1~24 ，存储当前关卡的6个坑是哪几幅图
		private var holesIndex : Array = [];
		//
		// 选项槽位里的当前空位
		private var emptyChoicesIndex : Array = [0, 1, 2];

		public function TZGame()
		{
			//
			ui = new UITZGame();
			ui.bottom.y = GameConf.VISIBLE_SIZE_H_MINUS_AD;
			ui.win.visible = false;
			addChild(ui);

			this.addEventListener(MouseEvent.MOUSE_DOWN, onWinDown);
			ui.bottom.nextBtn.visible = false;
			ui.bottom.nextBtn.addEventListener(MouseEvent.CLICK, onNextBtnClick);
            //
			levelModel = TZLevelModel.getInstance();
			nextI = (levelModel.level-1) * TZLevelModel.BIRDSCOUNT_INLEVEL;
			//
			makeAnimalHoles();
			//
			_shine = new Shine();
			ui.addChildAt(_shine,ui.getChildIndex(ui.win));
			//
			ui.backBtn.addEventListener(MouseEvent.CLICK, onBackClick);
			// 监听拖拽完成 判定
			this.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);

			makeAnimalDragSources();
			//

			changeLevel(levelModel.level);
		}

		private function onWinDown(event : MouseEvent) : void
        {
            ui.win.visible = false;
			if(_delayWin)
			{
				_delayWin = false;
				SoundMan.playSfx(SoundMan.PRIZE);
            }
		}

		private function onNextBtnClick(event : MouseEvent) : void
		{
			SoundMan.playSfx(SoundMan.BTN);
			if( (levelModel.levelCount> levelModel.level ) )
			{
				levelModel.level +=1;
				changeLevel( levelModel.level );
			}
		}

		public function changeLevel(level : int) : void
		{
			//
			_shine.visible = false;
			_shine.stop();
			// ui
			ui.win.visible = false;
			ui.bottom.nextBtn.visible = false;
			//
			levelModel = TZLevelModel.getInstance();
			nextI = (levelModel.level-1) * TZLevelModel.NEWBIRDSCOUNT_INLEVEL;

			var toFrame : int = level % ui.bg.totalFrames;
			if(toFrame == 0) toFrame= ui.bg.totalFrames;
			ui.bg.gotoAndStop( toFrame );

			// shelf holes
			holesIndex = [];
			holeShelf.setList([1, 2, 3, 4]);
			targetsLeft = holeShelf.numChildren;
			holesIndex.sort(randomSort);
			// choices
			for (var i : int = 0; i < 3; i++)
			{
				animalSelectionFlyIn();
			}
			AoaoBridge.banner(YiZhiDaQuan.instance);
		}

		// 判定是否拖拽到合适地点
		private function onMouseUp(event : MouseEvent) : void
		{
			var dragHoleLi : TZHoleLi = event.target as TZHoleLi;
			if (dragHoleLi == null ) return ;
			if (dragHoleLi.type == TZHoleLi.DRAG_TARGET) return ;
			var numShelfChildren : int = holeShelf.numChildren;
			for (var i : int = 0; i < numShelfChildren; i++)
			{
				var shelfLi : TZHoleLi = holeShelf.getChildAt(i) as TZHoleLi;
				if (dragHoleLi.index == shelfLi.index)
				{
					var shelfLiPos : Point = shelfLi.centerPos;
					var dragLiPos : Point = dragHoleLi.centerPos;
                    trace("mouseUp,shelfLiPos=",shelfLiPos,dragLiPos);
                    trace("shelfLi",shelfLi.x ,shelfLi.y);
                    trace("dragLiPos",dragHoleLi.x ,dragHoleLi.y);
					var dist : Number = MousebombMath.distanceOf2Point(shelfLiPos, dragLiPos);
					if (dist < 80)
					{
						userCorrect(dragHoleLi, shelfLi);
					}
				}
			}
		}
private var _shine:MovieClip;
		/**
		 * 玩家拖拽正确啦
		 */
		private function userCorrect(dragHoleLi : TZHoleLi, shelfHoleLi : TZHoleLi) : void
		{
			dragHoleLi.playCorrect();
			shelfHoleLi.playCorrect();
			// shanshan
			_shine.x = holeShelf.x + shelfHoleLi.x + HOLE_W/2;
			_shine.y = holeShelf.y + shelfHoleLi.y + HOLE_H /2;
			_shine.play();
			_shine.visible = true;
			// 空位记录
			emptyChoicesIndex.push(dragHoleLi.choiceIndex);
			// 显示读音拼音
			ui.win.gotoAndStop(shelfHoleLi.index);
			ui.win.visible = true;
			ui.win.x = this.mouseX ;
			ui.win.y = this.mouseY ;
			ui.win.scaleX = ui.win.scaleY = 0.01;
			TweenLite.to(ui.win,0.5,{scaleX:1.0 , scaleY : 1.0 , x : GameConf.DESIGN_SIZE_W/2, y : GameConf.VISIBLE_SIZE_H_MINUS_AD/2 , ease:Back.easeOut});
			SoundMan.playPic(dragHoleLi.index);
			// 得分增加
			if (--targetsLeft < 1)
			{
				//
				trace("胜利");
				levelModel.saveLevel(levelModel.level, 1);
				// 根据是否还有下一关 出不出下一关按钮
                playWinEffect(levelModel.levelCount> levelModel.level);
//				ui.bottom.nextBtn.visible =  (levelModel.levelCount> levelModel.level );

				_delayWin  = true;

				AoaoBridge.interstitial(YiZhiDaQuan.instance);
			}
			else
			{
				// 没胜利 ，继续出
				animalSelectionFlyIn();
			}
		}
        private function playWinEffect( showNextBtn :Boolean ):void
        {
            if(showNextBtn)
            {
                setTimeout(function():void
                {
                    ui.bottom.nextBtn.visible = true;
                    var oldY:Number = ui.bottom.nextBtn.y;
                    ui.bottom.nextBtn.y +=200;
                    TweenLite.to(ui.bottom.nextBtn,.8,{y:oldY,ease:Back.easeOut});
                },1200 );
            }
        }

		// 点击关闭win窗口提示后 再胜利
		private var _delayWin :Boolean = false;

		private function makeAnimalDragSources() : void
		{
			choiceContainer.y = GameConf.VISIBLE_SIZE_H_MINUS_AD - SELECTPANEL_HEIGHT;
			addChild(choiceContainer);
		}

		private function animalSelectionFlyIn() : void
		{
			// 获取一个要的
			// 随机的洞（target）里的index （pic的取值范围 1～24）
			if (holesIndex.length < 1) return;
			var pickHoleIndex : int = holesIndex.pop();
			// 第几个选项 0～3
			var pickChoiceIndex : int = emptyChoicesIndex.shift();
			var li : TZHoleLi = newHoleLiFromPicI(pickHoleIndex, TZHoleLi.DRAG_SOURCE);
			li.choiceIndex = pickChoiceIndex;
			li.x = TZGame.SELECTION_X[pickChoiceIndex];
			li.alpha = 0;
			TweenLite.to(li,0.6,{alpha:1});
			choiceContainer.addChild(li);
		}

		/**
		 * 创建／装饰 TZHoleLi  i是PicI
		 * type 决定是被拖拽的source  还是 被防止的target
		 */
		private function newHoleLiFromPicI(i : int, type : String, li : TZHoleLi = null) : TZHoleLi
		{
			if (li == null)
			{
				li = new TZHoleLi();
			}
			var clazz : Class = getDefinitionByName("Pic" + i) as Class;
			var child : Sprite = new clazz() as Sprite;
			var holeW :Number = HOLE_W;
			var holeH :Number = HOLE_H;
			if(type == TZHoleLi.DRAG_SOURCE)
			{
				holeW = TZHoleLi.HOLE_W_SMALL;
				holeH = TZHoleLi.HOLE_H_SMALL;
			}
			var sx : Number = holeW / child.width ;
			var sy : Number = holeH / child.height ;
			var scale : Number = sx < sy ? sx : sy;
			child.scaleX = child.scaleY = scale;
			child.x = holeW / 2;
			child.y = holeH / 2;
			if (type == TZHoleLi.DRAG_TARGET)
			{
				holesIndex.push(i);
			}
			//
			//
			li.setContent(child, i, type);
			return li;
		}

		private function onBackClick(event : MouseEvent) : void
		{
			YiZhiDaQuan.instance.replaceScene(new TZLevel());
			AoaoBridge.interstitial(YiZhiDaQuan.instance);
		}

		private static var nextI : int = 1;
		// shelf 180 ===  SHELFH 445  ===  BOTTOM
		// 上面ui尺寸
		private static const MENUPANEL_TOP : Number = 130;
//		private static const HOLE_SHELF_TOP : Number = 180;
		// 下面ui尺寸 广告以外的
		private static const BOTTOM_HEIGHT : Number = 200;
		// 下方选项占用的高度 广告以外
		private static const SELECTPANEL_HEIGHT : Number = 162.5;
		private static const HOLE_W : Number = TZHoleLi.HOLE_W;
		private static const HOLE_H : Number = TZHoleLi.HOLE_H;
		// 本关还剩余目标数
		private var  targetsLeft : int = 4;

		private function makeAnimalHoles() : void
		{
			//
			holeShelf = new Shelf();

			ui.addChildAt(holeShelf,ui.getChildIndex(ui.win));
			var shelfW : Number = GameConf.VISIBLE_SIZE_W * 0.5 + HOLE_W;
			var shelfH : Number = (GameConf.VISIBLE_SIZE_H_MINUS_AD -BOTTOM_HEIGHT - MENUPANEL_TOP) * 0.5 + HOLE_H;

			holeShelf.x = (GameConf.DESIGN_SIZE_W - shelfW) / 2 ;
			holeShelf.y = ((GameConf.VISIBLE_SIZE_H_MINUS_AD -BOTTOM_HEIGHT - MENUPANEL_TOP) - shelfH )/2 + MENUPANEL_TOP;
			holeShelf.autoConfig(shelfW, shelfH, HOLE_W, HOLE_H, 2, 2, TZHoleLi, onLiAdded);

			// SELECTION_X 计算 跟这里统一
			for (var i : int = 0; i < 3; i++)
				SELECTION_X[i] = holeShelf.x + shelfW / 3 * i ;
			//
		}

		private function randomSort(elementA : Object, elementB : Object) : int
		{
			return int(Math.random() * 3) - 1;
		}

		private function onLiAdded(li : TZHoleLi, vo : int) : void
		{
			newHoleLiFromPicI((nextI++) % GameConf.TS_PIC_NUM + 1, TZHoleLi.DRAG_TARGET, li);
		}

		public function dispose() : void
		{
		}

		public function flyIn() : void
		{
		}
	}
}
