package org.mousebomb {

	import flash.ui.Keyboard;

	import starling.core.Starling;
	import com.aoaogame.sdk.core.image.JPGEncoder;

	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.KeyboardEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	/**
	 * @author Administrator
	 */
	public class ScreenshotHelper {
		private static var game : DisplayObject;
		
		private static var nextI : int = 1;

		private static function onKeyDown(event : KeyboardEvent) : void {
			if(event.keyCode == Keyboard.SPACE)
			{
				SoundMan.playSfx(SoundMan.BTN);
				var sc : BitmapData = new BitmapData(game.stage.fullScreenWidth, game.stage.fullScreenHeight);
				Starling.current.stage.drawToBitmapData(sc);
				var jpg :JPGEncoder = new JPGEncoder();
				var file :File = File.desktopDirectory.resolvePath("TD"+GameConf.AOAO_APP_ID+"-"+sc.width+"x"+sc.height+"-"+nextI+".jpg");
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
