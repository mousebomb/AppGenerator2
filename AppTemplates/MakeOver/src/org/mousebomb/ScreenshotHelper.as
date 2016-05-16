package org.mousebomb {
	import flash.utils.ByteArray;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.filesystem.File;
	import com.aoaogame.sdk.core.image.JPGEncoder;
	import flash.display.DisplayObject;
	import flash.display.BitmapData;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
import flash.display.Sprite;
import com.greensock.TweenLite;


	/**
	 * @author Administrator
     * 闪烁模式
	 */
	public class ScreenshotHelper {
		private static var game : DisplayObject;
		
		private static var nextI : int = 1;

        private static var flash: Sprite;

		private static function onKeyDown(event : KeyboardEvent) : void {
			if(event.keyCode == Keyboard.SPACE){
				var sc : BitmapData = new BitmapData(game.stage.fullScreenWidth, game.stage.fullScreenHeight);
				sc.draw(game);
				var jpg :JPGEncoder = new JPGEncoder();
				var file :File = File.desktopDirectory.resolvePath("Game"+GameConf.AOAO_APP_ID+"-"+sc.width+"x"+sc.height+"-"+nextI+".jpg");
				nextI++;
				var jpgData : ByteArray = jpg.encode(sc);
				var fs :FileStream = new FileStream();
				fs.open(file, FileMode.WRITE);
				fs.writeBytes(jpgData);
				fs.close();
                showFlash();
            }
		}

		public static function init(game : DisplayObject) : void {
			ScreenshotHelper.game = game;
			game.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}

        private static function showFlash():void
        {
            if(null == flash )
            {
                flash = new Sprite();
                flash.graphics.beginFill(0xffffff);
                flash.graphics.drawRect(0,0,game.stage.fullScreenWidth, game.stage.fullScreenHeight);
                flash.mouseEnabled = false;
                game.stage.addChild(flash);
            }
            TweenLite.to(flash,0.5,{alpha : 0 });
        }
	}
}
