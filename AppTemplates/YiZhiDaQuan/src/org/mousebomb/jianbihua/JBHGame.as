package org.mousebomb.jianbihua {

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.media.CameraRoll;

	import org.mousebomb.GameConf;
	import org.mousebomb.IFlyIn;
	import org.mousebomb.SoundMan;
	import org.mousebomb.interfaces.IDispose;
	import org.mousebomb.ui.Shelf;

	import yizhidaquan.YiZhiDaQuan;

	/**
	 * @author rhett
	 */
	public class JBHGame extends Sprite implements IFlyIn ,IDispose {
		private var jbh : JBHPaint;
		private var levelModel : JBHLevelModel;
		private var ui : UIJBHGame;
		private var colorShelf : Shelf;
		private var brushSizeBtnsHelper : BrushSizeBtnsHelper;
		public var colors : Array = [0xFF9999, 0x79E3E1, 0x9AC43A, 0xFFCC00, 0x6CA233, 0xFF9900, 0xFF6699, 0x0075BB, 0x000000];

		public function JBHGame() {
			levelModel = JBHLevelModel.getInstance();

			jbh = new JBHPaint();

			// UI
			ui = new UIJBHGame();
			ui.bottom.y = GameConf.VISIBLE_SIZE_H_MINUS_AD;
			ui.backBtn.addEventListener(MouseEvent.CLICK, onBackClick);
			ui.bottom.brushSizeBtn.addEventListener(MouseEvent.CLICK, onBrushSizeClick);
			ui.bottom.eraseBtn.addEventListener(MouseEvent.CLICK, onEraseClick);
			colorShelf = new Shelf();
			colorShelf.x = 307 + 40;
			colorShelf.y = -165 + 40;
			colorShelf.autoConfig(380, 132, 64, 64, 5, 2, ColorSample, onAddColorSampleLi);
			ui.bottom.addChild(colorShelf);
			colorShelf.setList(colors);
			ui.bottom.eraseBtn.gotoAndStop(1);
			brushSizeBtnsHelper = new BrushSizeBtnsHelper(new Point(ui.bottom.brushSizeBtn.x, ui.bottom.brushSizeBtn.y), ui.bottom.size1, ui.bottom.size2, ui.bottom.size3);
			ui.bottom.size1.addEventListener(MouseEvent.CLICK, onSizeBtnClick);
			ui.bottom.size2.addEventListener(MouseEvent.CLICK, onSizeBtnClick);
			ui.bottom.size3.addEventListener(MouseEvent.CLICK, onSizeBtnClick);
			ui.saveBtn.visible = CameraRoll.supportsAddBitmapData;
			ui.saveBtn.addEventListener(MouseEvent.CLICK, onSaveClick);

			// 画布
			jbh.y = ui.top.height;
			jbh.setContentSize(GameConf.DESIGN_SIZE_W, GameConf.VISIBLE_SIZE_H_MINUS_AD - 200 - ui.top.height);
			jbh.proxy.onChanged = onPaintChanged;

			addChild(jbh);
			addChild(ui);

			if(stage){
				onStage(null);
			}else{
				this.addEventListener(Event.ADDED_TO_STAGE, onStage);
			}
		}
		
		private function onPaintChanged():void
		{
			ui.saveBtn.visible = true;
		}

		private function onSaveClick(event : MouseEvent) : void {
			ui.saveBtn.visible = false;
			jbh.save();
		}

		private function onSizeBtnClick(event : MouseEvent) : void {
			var size : int = int((event.target  as DisplayObject).name.substr(4));
			jbh.proxy.brushSize = size * 5;
			brushSizeBtnsHelper.close();
		}

		private function onAddColorSampleLi(li : ColorSample, vo : *) : void {
			li.stop();
			var ct : ColorTransform = new ColorTransform();
			ct.color = vo;
			li.vo = vo;
			li.c.transform.colorTransform = ct;
			li.addEventListener(MouseEvent.CLICK, onColorLiClick);
		}

		private var selectedBrush : ColorSample;

		private function onColorLiClick(event : MouseEvent) : void {
			if (selectedBrush) {
				selectedBrush.gotoAndStop(1);
			}
			if (jbh.proxy.erase) {
				jbh.proxy.erase = false;
				ui.bottom.eraseBtn.gotoAndStop(1);
			}
			var li : ColorSample = event.currentTarget as ColorSample;
			li.gotoAndStop(2);
			var color : uint = li.vo;
			// var cIndex :int = colors.indexOf(color);
			// Sfx.color.gotoAndStop(cIndex+10);
			selectedBrush = li;
			jbh.proxy.color = color;
		}

		private function onEraseClick(event : MouseEvent) : void {
			if (selectedBrush) {
				selectedBrush.gotoAndStop(1);
			}

			jbh.proxy.erase = true;
			ui.bottom.eraseBtn.gotoAndStop(2);
		}

		private function onBrushSizeClick(event : MouseEvent) : void {
			// 弹出选择size的按钮
			brushSizeBtnsHelper.open();
		}

		private function onBackClick(event : MouseEvent) : void {
			SoundMan.playSfx(SoundMan.BTN);
			YiZhiDaQuan.instance.replaceScene(new JBHLevel());
		}

		private function onStage(event : Event) : void {
			jbh.startPaint(levelModel.level);
			this.removeEventListener(Event.ADDED_TO_STAGE, onStage);
			AoaoBridge.banner(YiZhiDaQuan.instance);
			//
			SoundMan.playPic(levelModel.level);
        }

		public function flyIn() : void {
		}

		public function dispose() : void {
			jbh.proxy.dispose();
			// 广告
			AoaoBridge.interstitial(YiZhiDaQuan.instance);
		}
	}
}
