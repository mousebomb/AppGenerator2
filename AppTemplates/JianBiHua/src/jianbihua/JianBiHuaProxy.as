package jianbihua {
	import org.mousebomb.interfaces.IDispose;
	import flash.display.BlendMode;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	/**
	 * @author rhett
	 */
	public class JianBiHuaProxy implements IDispose{
		private var target : Sprite;
		private var g : Graphics;
		
		/**
		 * 内容改动了回调
		 */
		public var onChanged:Function;

		public function adapt(target : Sprite) : void {
			this.target = target;

			// 白色＝ 透明  DARKEN
			// 只能绘制到黑色区域上 SCREEN
//			target.blendMode = BlendMode.DARKEN;
			g = target.graphics;

			target.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			target.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}

		private function onMouseUp(event : MouseEvent) : void {
			target.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
			if(onChanged!=null) onChanged();
		}

		private function onMouseDown(event : MouseEvent) : void {
			drawDot(target.mouseX, target.mouseY);
			target.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
		}

		private function onMove(event : MouseEvent) : void {
			// target.graphics.lineStyle(2);
			drawLineTo(target.mouseX, target.mouseY);
		}

		private var lastPos : Point = new Point();
		public var color : uint = 0x000000;
		public var colorErase : uint = 0xFFFFFF;
		public var  brushSize : Number = 15.0;
		public var alpha : Number = 1.0;

		/**
		 * 画点
		 */
		private function drawDot(x : Number, y : Number) : void {
			var realColor : uint = erase ? colorErase : color;
			var realBrushSize : Number = erase ? brushSize * 2 : brushSize;
			g.lineStyle(realBrushSize, realColor, alpha);
			g.moveTo(x, y);
			g.lineTo(x, y);
			lastPos.x = x;
			lastPos.y = y;
		}

		/**
		 * 从最近画点的地方开始连线
		 */
		private function drawLineTo(x : Number, y : Number) : void {
			g.moveTo(lastPos.x, lastPos.y);
			g.lineTo(x, y);
			lastPos.x = x;
			lastPos.y = y;
		}

		public var erase : Boolean = false;

		public function dispose() : void {
			target.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
			target.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			target.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
	}
}
