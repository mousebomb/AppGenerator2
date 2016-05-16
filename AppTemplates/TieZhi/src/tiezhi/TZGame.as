package tiezhi
{
	import com.greensock.TweenLite;
	import org.mousebomb.SoundMan;
	import org.mousebomb.IFlyIn;
	import org.mousebomb.Math.MousebombMath;
	import org.mousebomb.GameConf;
	import org.mousebomb.interfaces.IDispose;
	import org.mousebomb.ui.Shelf;

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
import flash.utils.setTimeout;

import com.greensock.TweenLite;
import com.greensock.easing.Back;

	/**
	 * @author rhett
	 */
	public class TZGame extends Sprite implements IDispose,IFlyIn
	{
		private var ui : UIGame;
		private var levelModel : LevelModel;
		private var bg : Scenes;
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
			ui = new UIGame();
			ui.bottom.y = GameConf.VISIBLE_SIZE_H;
			ui.win.visible = false;
			ui.bottom.nextBtn.visible = false;
			ui.bottom.nextBtn.addEventListener(MouseEvent.CLICK, onNextBtnClick);
            //
            ui.win.addEventListener(MouseEvent.CLICK,onWinClick);
			//
			levelModel = LevelModel.getInstance();
			nextI = levelModel.level * LevelModel.BIRDSCOUNT_INLEVEL;
			//
			makeScene();
			makeAnimalHoles();
			//
			_shine = new Shine();
			addChild(_shine);
			//
			addChild(ui);
			ui.backBtn.addEventListener(MouseEvent.CLICK, onBackClick);
			// 监听拖拽完成 判定
			this.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);

			makeAnimalDragSources();
			//

			changeLevel(levelModel.level);
		}

        private function onWinClick(e:MouseEvent):void
        {
            ui.win.visible = false;
        }

		private function onNextBtnClick(event : MouseEvent) : void
		{
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
			levelModel = LevelModel.getInstance();
			nextI = levelModel.level * LevelModel.NEWBIRDSCOUNT_INLEVEL;

			bg.gotoAndStop(level % bg.totalFrames + 1);

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
			AoaoBridge.banner(this);
		}

		// 判定是否拖拽到合适地点
		private function onMouseUp(event : MouseEvent) : void
		{
			var dragHoleLi : HoleLi = event.target as HoleLi;
			if (dragHoleLi == null ) return ;
			if (dragHoleLi.type == HoleLi.DRAG_TARGET) return ;
			var numShelfChildren : int = holeShelf.numChildren;
			for (var i : int = 0; i < numShelfChildren; i++)
			{
				var shelfLi : HoleLi = holeShelf.getChildAt(i) as HoleLi;
				if (dragHoleLi.index == shelfLi.index)
				{
					var shelfLiPos : Point = shelfLi.localToGlobal(new Point());
					var dragLiPos : Point = dragHoleLi.localToGlobal(new Point());
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
		private function userCorrect(dragHoleLi : HoleLi, shelfHoleLi : HoleLi) : void
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
			// 得分增加
			if (--targetsLeft < 1)
			{
				//
				trace("胜利");
				levelModel.saveLevel(levelModel.level, 1);
				// 根据是否还有下一关 出不出下一关按钮
                playWinEffect(levelModel.levelCount> levelModel.level);
//				ui.bottom.nextBtn.visible =  (levelModel.levelCount> levelModel.level );
//				ui.win.visible = true;
				SoundMan.playSfx(SoundMan.PRIZE);
				
				AoaoBridge.interstitial(this);
			}
			else
			{
				SoundMan.playSfx(SoundMan.RIGHT);
				// 没胜利 ，继续出
				animalSelectionFlyIn();
			}
		}
        private function playWinEffect( showNextBtn :Boolean ):void
        {
            ui.win.visible = true;
            ui.win.scaleX = ui.win.scaleY = 0.01;

            TweenLite.to(ui.win,1,{scaleX:1,scaleY:1,ease:Back.easeOut});
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
			var li : HoleLi = newHoleLiFromPicI(pickHoleIndex, HoleLi.DRAG_SOURCE);
			li.choiceIndex = pickChoiceIndex;
			li.x = TZGame.SELECTION_X[pickChoiceIndex];
			li.alpha = 0;
			TweenLite.to(li,0.6,{alpha:1});
			choiceContainer.addChild(li);
		}

		/**
		 * 创建／装饰 HoleLi  i是PicI
		 * type 决定是被拖拽的source  还是 被防止的target
		 */
		private function newHoleLiFromPicI(i : int, type : String, li : HoleLi = null) : HoleLi
		{
			if (li == null)
			{
				li = new HoleLi();
			}
			var clazz : Class = getDefinitionByName("Pic" + i) as Class;
			var child : MovieClip = new clazz() as MovieClip;
			var holeW :Number = HOLE_W;
			var holeH :Number = HOLE_H;
			if(type == HoleLi.DRAG_SOURCE)
			{
				holeW = HoleLi.HOLE_W_SMALL;
				holeH = HoleLi.HOLE_H_SMALL;
			}
			var sx : Number = holeW / child.width ;
			var sy : Number = holeH / child.height ;
			var scale : Number = sx < sy ? sx : sy;
			child.scaleX = child.scaleY = scale;
			child.x = holeW / 2;
			child.y = holeH / 2;
			if (type == HoleLi.DRAG_TARGET)
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
			TieZhi.instance.replaceScene(new TZLevel());
			if (!CONFIG::DEBUG)
			{
				AoaoBridge.interstitial(this);
			}
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
		private static const HOLE_W : Number = HoleLi.HOLE_W;
		private static const HOLE_H : Number = HoleLi.HOLE_H;
		// 本关还剩余目标数
		private var  targetsLeft : int = 4;

		private function makeAnimalHoles() : void
		{
			//
			holeShelf = new Shelf();

			addChild(holeShelf);
			var shelfW : Number = GameConf.VISIBLE_SIZE_W * 0.5 + HOLE_W;
			var shelfH : Number = (GameConf.VISIBLE_SIZE_H_MINUS_AD -BOTTOM_HEIGHT - MENUPANEL_TOP) * 0.5 + HOLE_H;

			holeShelf.x = (GameConf.DESIGN_SIZE_W - shelfW) / 2 ;
			holeShelf.y = ((GameConf.VISIBLE_SIZE_H_MINUS_AD -BOTTOM_HEIGHT - MENUPANEL_TOP) - shelfH )/2 + MENUPANEL_TOP;
			holeShelf.autoConfig(shelfW, shelfH, HOLE_W, HOLE_H, 2, 2, HoleLi, onLiAdded);

			// SELECTION_X 计算 跟这里统一
			for (var i : int = 0; i < 3; i++)
				SELECTION_X[i] = holeShelf.x + shelfW / 3 * i ;
			//
		}

		private function randomSort(elementA : Object, elementB : Object) : int
		{
			return int(Math.random() * 3) - 1;
		}

		private function onLiAdded(li : HoleLi, vo : int) : void
		{
			newHoleLiFromPicI((nextI++) % GameConf.PIC_NUM + 1, HoleLi.DRAG_TARGET, li);
		}

		private function makeScene() : void
		{
			bg = new Scenes();
			bg.gotoAndStop(1);
			addChildAt(bg, 0);
			//
		}

		public function dispose() : void
		{
		}

		public function flyIn() : void
		{
		}
	}
}
