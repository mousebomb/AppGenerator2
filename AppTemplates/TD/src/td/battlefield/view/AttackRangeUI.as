package td.battlefield.view
{
	import flash.geom.Matrix;
	import flash.display.BitmapData;

	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;

	import flash.display.Shape;

	/**
	 * @author rhett
	 */
	public class AttackRangeUI extends Sprite
	{
		private var tween : Tween;

		public static const DEFAULT_RANGE:Number=150;
		public function AttackRangeUI()
		{
			if (rangeT == null)
			{
				var s : Shape = new Shape();
				s.graphics.clear();
				s.graphics.beginFill(0x0, 0.4);
				s.graphics.lineStyle(2, 0xffffff);
				s.graphics.drawCircle(0, 0, DEFAULT_RANGE);
				var bmd : BitmapData = new BitmapData(s.width, s.height,true,0);
				var mtx :Matrix = new Matrix();
				mtx.translate(DEFAULT_RANGE+1, DEFAULT_RANGE+1);
				bmd.drawWithQuality(s,mtx,null,null,null,true,null);
				rangeT = Texture.fromBitmapData(bmd);
			}
			this.touchable=false;
		}

		private static var rangeT : Texture;

private var img :Image;
		public function setRadius(r : Number) : void
		{
			if (img == null)
			{
				img = new Image(rangeT);
				img.alignPivot();
				addChild(img);
			}
			img.scaleX=img.scaleY = r/DEFAULT_RANGE;

			// flyin
			this.scaleX = .1;
			this.scaleY = .1;
			tween = new Tween(this, 0.4, Transitions.EASE_OUT_BACK);
			tween.animate("scaleX", 1);
			tween.animate("scaleY", 1);
			// tween.fadeTo( .5 );
			Starling.juggler.add(tween);
		}
		// private			var s :Shape = new Shape();

		// private function makeRange(r : uint) : Texture
		// {
		// s.graphics.drawCircle(0, 0, r);
		// addChild(s);
		// }
	}
}
