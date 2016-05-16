package jianbihua {
	import com.greensock.easing.Back;
	import com.greensock.TweenLite;

	import flash.display.SimpleButton;
	import flash.geom.Point;
	import flash.utils.Dictionary;

	/**
	 * @author rhett
	 */
	public class BrushSizeBtnsHelper {
		private var btns : Array = [];
		private var origPos : Dictionary = new Dictionary(true);
		private var startPos : Point;

		public function BrushSizeBtnsHelper(startPos : Point, ...btn_) {
			this.startPos = startPos;
			btns = btn_;
			for each (var eachBtn : SimpleButton in btns) {
				origPos[eachBtn] = new Point(eachBtn.x, eachBtn.y);
				eachBtn.visible = false;
			}
		}

		public function open() : void {
			for each (var eachBtn : SimpleButton in btns) {
				var pos : Point = origPos[eachBtn];
				eachBtn.x = startPos.x ;
				eachBtn.y = startPos.y;
				eachBtn.visible = true;
				eachBtn.scaleX=eachBtn.scaleY = 0.01;
				TweenLite.to(eachBtn, 0.5, {x:pos.x, y:pos.y,scaleX:1,scaleY:1, ease:Back.easeInOut});
			}
		}

		public function close() : void {
			for each (var eachBtn : SimpleButton in btns) {
				eachBtn.visible = true;
				TweenLite.to(eachBtn, 0.5, {x:startPos.x, y:startPos.y,scaleX:0.01,scaleY :0.01, onComplete:onHideComp , ease:Back.easeInOut});
			}
		}

		private function onHideComp() : void {
			for each (var eachBtn : SimpleButton in btns) {
				eachBtn.visible = false;
			}
		}
	}
}
