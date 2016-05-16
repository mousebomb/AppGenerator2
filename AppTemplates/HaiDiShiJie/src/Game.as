package
{

	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.filesystem.File;

	import hdsj.TimuModel;
	import hdsj.TimuService;
	import hdsj.YuChang;
	import hdsj.YuChangModel;
	import hdsj.ui.UIMain;
	import hdsj.ui.UIWarning;

	import org.mousebomb.GameConf;
	import org.mousebomb.IFlyIn;
	import org.mousebomb.SoundMan;
	import org.mousebomb.interfaces.IDispose;

	/**
	 * @author rhett
	 */
	public class Game extends AoaoGame
	{
		public static var instance:Game;

		public function Game()
		{
			instance = this;
		}

		private var yuchang:YuChang;
		override protected function start():void
		{
			super.start();
//				addChild(new Test());
//			return ;
			//
			var bgMusic:File = File.applicationDirectory.resolvePath( "bgm.mp3" );
			if( bgMusic.exists )
			{
				SoundMan.playBgm( bgMusic.url );
			}
			YuChangModel.getInstance();
			yuchang = new YuChang();
			rootView.addChildAt(yuchang,0);
			trace(yuchang.width,yuchang.height);
			_scene = new UIMain();
			rootView.addChild( _scene );
			trace("rootViewSize=",rootView.width,rootView.x);
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;

			//
			var timuService :TimuService= new TimuService();
			timuService.timuModel = timuModel=new TimuModel();
			timuService.loadTimu();
		}


		public static var timuModel:TimuModel;
		private var _scene:DisplayObject;


		public function replaceScene( scene:Sprite ):void
		{
			(_scene as IDispose).dispose();
			rootView.removeChild( _scene );
			_scene = scene;
			if( scene is IFlyIn )(scene as IFlyIn).flyIn();
			rootView.addChild( scene );
		}


		public static function warning(prompt :String ):void
		{
			var w:UIWarning = new UIWarning(prompt);
			w.x = Game.instance.rootView.mouseX;
			w.y = Game.instance.rootView.mouseY;
			if(w.x + w.width > GameConf.VISIBLE_SIZE_W)
			{
				w.x = GameConf.VISIBLE_SIZE_W - w.width;
			}
			if(w.y + w.height>GameConf.VISIBLE_SIZE_H_MINUS_AD)
			{
				w.y = GameConf.VISIBLE_SIZE_H_MINUS_AD - w.height;
			}
			Game.instance.rootView.addChild( w );
		}

	}
}
