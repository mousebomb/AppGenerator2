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

	/**
	 * @author Administrator
	 */
	public class ScreenshotHelper {
		private static var game : DisplayObject;
		
		private static var nextI : int = 1;

		private static function onKeyDown(event : KeyboardEvent) : void {
			if(event.keyCode == Keyboard.SPACE){
				SoundMan.playSfx(SoundMan.FINISH);
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
			}
		}

		public static function init(game : DisplayObject) : void {
			ScreenshotHelper.game = game;
			game.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
	}
}
