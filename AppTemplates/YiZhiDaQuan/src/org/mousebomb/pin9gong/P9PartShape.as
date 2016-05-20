package org.mousebomb.pin9gong
{

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	import gs.TweenLite;
	import gs.easing.Back;

	/**
	 * @author rhett
	 */
	public class P9PartShape extends Sprite
	{

		/** 正确的位置id */
		public var correctPos:int;
		/** 当前位置 */
		public var curPos:int;
		private var _onPartMoveComplete:Function;


		public function P9PartShape(bitmap : Bitmap, rect : Rectangle ,correctPos : int ,curPos:int )
		{
			this.correctPos = correctPos;
			this.curPos = curPos;
			var bmd :BitmapData = new BitmapData(rect.width,rect.height,true,0);
			var mtx :Matrix = new Matrix();
			mtx.scale(bitmap.scaleX,bitmap.scaleY);
			mtx.translate(-rect.x , -rect.y);
			bmd.draw(bitmap , mtx , null,null,new Rectangle(0,0,rect.width,rect.height));
			addChild( new Bitmap(bmd));
		}

		/** 移动到slot位置，并返回移动前的位置 */
		public function moveTo( x_:Number , y_:Number ,onPartMoveComplete:Function) :void
		{
			_onPartMoveComplete = onPartMoveComplete;
			TweenLite.to(this , 0.2 , {
				x : x_ , y:y_, onComplete:onTweenComplete ,ease :Back.easeOut
			});
		}

		private function onTweenComplete(  ):void
		{
			if(_onPartMoveComplete !=null) _onPartMoveComplete(this);
		}
	}
}
