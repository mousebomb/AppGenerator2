/**
 * Created by rhett on 15/4/5.
 */
package fan
{

	import com.greensock.TweenLite;
	import com.greensock.easing.Back;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;

	public class Card extends Sprite
	{

		/** 正面 */
		public var frontSpr : Sprite;
		public var front : Bitmap;
		/** 背面 */
		public var backSpr : Sprite;
		public var back : Bitmap;
		/** 下面的背景 */
		public var bg :Bitmap;

		public static var bgBmd:BitmapData;
		public static var backBmd:BitmapData;
		public static var frontBmd:BitmapData;


		public function Card()
		{
			frontSpr = new Sprite();
			backSpr = new Sprite();
			//
			back = new Bitmap(backBmd);
			front = new Bitmap(frontBmd);
			bg = new Bitmap(bgBmd);
			// 居中
			back.x  = -back.width / 2;
			back.y  = -back.height / 2;
			front.x = -front.width/2;
			front.y = -front.height/2;
			bg.x = -bg.width /2;
			bg.y = -bg.height /2;
//						frontSpr.x = front.width/2;
//						frontSpr.y = front.height/2;
//						backSpr.x  = back.width / 2;
//						backSpr.y  = back.height / 2;
//			bg.x = bg.width /2;
//			bg.y = bg.height /2;

			addChild(bg);
			frontSpr.addChild(front);
			backSpr.addChild(back);
			addChild(frontSpr);
			addChild(backSpr);
		}

		private var _id :int ;

		public function get id():int
		{
			return _id;
		}

		public function set id( value:int ):void
		{
			_id = value;
			var fileURL :String =LevelModel.getImageFile(_id).url;
			UniqLoader.getPic( fileURL , loaded );
		}

		private function loaded(bmd :BitmapData):void
		{
			var pic : Bitmap = new Bitmap(bmd);
			var sx : Number = (front.width-8) / pic.width ;
			var sy : Number = (front.height-8) / pic.height ;
			var scale : Number = sx < sy ? sx : sy;
			pic.scaleX = pic.scaleY = scale;
			pic.x = -pic.width/2;
			pic.y = -pic.height/2;
			this.frontSpr.addChild(pic);
		}

		/** 翻  反面到正面 */
		public function fan( cb :Function):void
		{
			trace("Card/fan()");
			fanCompCb = cb;
			TweenLite.to(this , 0.4, {flip : 0,onComplete:fanComplete});
		}
		private var fanCompCb:Function;

		private function fanComplete():void
		{
			if(null !=fanCompCb) fanCompCb(this);
		}

		/** 盖  正面到反面 */
		public function gai():void
		{
//trace("Card/gai()");
			TweenLite.to(this , 0.4, {flip : 1});
		}

		/** 正确  消失 */
		public function right():void
		{
//trace("Card/right()");
			TweenLite.to(this , 0.4 , {alpha : 0 , scaleX : 1.5,scaleY:1.5,ease:Back.easeOut , onComplete:remove});
		}

		private function remove():void
		{
			if(this.parent) this.parent.removeChild(this);
		}

		/** 翻度 0正 1反 */
		private var _flip : Number = 0;
		public function get flip():Number
		{
			return _flip;
		}

		public function set flip( value:Number ):void
		{
			_flip = value;
			frontSpr.visible = _flip <.5;
			backSpr.visible = _flip>.5;
			var scale:Number  =  Math.abs(.5 - _flip )/.5;
			backSpr.scaleX = frontSpr.scaleX = scale;
		}
	}
}

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.filesystem.File;
import flash.net.URLRequest;
import flash.utils.Dictionary;

class UniqLoader
{
	public function UniqLoader()
	{

	}

	/** 所有外部pic的图 */
	public static var bmdDic :Dictionary = new Dictionary();
	/** 需要的cb */
	public static var cbDic :Dictionary = new Dictionary();

	private static var isLoading:Dictionary = new Dictionary();

	private static function load( fileURL :String  ):void
	{
		if(isLoading[fileURL]) return ;
		var loader:Loader = new Loader();
		loader.load( new URLRequest( fileURL ) );
		trace("UniqLoader/load()",fileURL);
		loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onLoadLevelComp );
		isLoading[fileURL] = true;
	}

	/** cb参数(bitmapData) */
	public static function getPic( fileURL:String ,cb :Function ) :void
	{
		var bmd :BitmapData = bmdDic[fileURL];
		if(bmd)
		{
			cb(bmd);
		}else{
			if(null == cbDic[fileURL]){ cbDic[fileURL] = [];}
			cbDic[fileURL].push(cb);
			load(fileURL);
		}
	}

	private static function onLoadLevelComp( event:Event ):void
	{
		var loader:Loader = (event.currentTarget as LoaderInfo).loader;
		var fileURL :String = (event.currentTarget as LoaderInfo).url;
		var bmp :Bitmap= loader.content as Bitmap;
		isLoading[fileURL] = false;
		bmdDic[fileURL] = bmp.bitmapData;
		if(cbDic[fileURL]!=null)
		{
			var cbs :Array = cbDic[fileURL];
			for( var i:int = 0; i < cbs.length; i++ )
			{
				var cb:Function = cbs[i];
				cb(bmp.bitmapData);
			}
			cbDic[fileURL] = null;
		}
	}
}