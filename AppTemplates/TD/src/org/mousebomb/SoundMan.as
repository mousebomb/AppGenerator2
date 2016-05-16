package org.mousebomb
{

	import flash.desktop.NativeApplication;
	import flash.filesystem.File;
	import flash.media.SoundChannel;
	import flash.media.Sound;
	import flash.net.URLRequest;
    import flash.utils.getTimer;
    import flash.utils.Dictionary;
	import starling.utils.AssetManager;

	/**
	 * @author Mousebomb
	 */
	public class SoundMan
	{
		private static var _isMute : Boolean = false;

		public static function init() : void
		{
		}


		static private var bgm : Sound;
		static private var soundChannel : SoundChannel;
		private static var curBgmFile : String;

		static public function playBgm(b : String) : void
		{
			if (bgm == null)
			{
				bgm = new Sound();
			}
			if (b != curBgmFile)
			{
				SoundMan.curBgmFile = b;
				try
				{
					bgm.close();
				}
				catch(e : *)
				{
				}
				bgm = new Sound();
				bgm.load(new URLRequest( TDGame.assetsFolder.url+"/sound/"+b));
				//
				if (soundChannel) soundChannel.stop();
				soundChannel = bgm.play(0, int.MAX_VALUE);
			}
		}

		public static function get isMute() : Boolean
		{
			return _isMute;
		}

		public static function set isMute(v : Boolean) : void
		{
			if (v == _isMute) return;
			SoundMan._isMute = v;
			if (_isMute == true)
			{
				if (soundChannel)
					soundChannel.stop();
			}
			else
			{
				playBgm(SoundMan.curBgmFile);
			}
		}

		public static function deactive() : void
		{
			if (soundChannel) SoundMan.soundChannel.stop();
		}

		public static function active() : void
		{
			if (!_isMute)
			{
				if (soundChannel) soundChannel.stop();
				if(bgm) 
					soundChannel = bgm.play(0, int.MAX_VALUE);
			}
		}

		//#3 sfx 改成用AssetsManager播
		/**  */
		public static const WON : String = "won";
		/**  */
		public static const LOST : String = "lost";
		/**  */
		public static const BTN : String = "btn";
		/**  */
		public static const MONSTER_DIE:String = "die";
		public static const BULLET_:String = "b";
		// 怪物出场音效（每波第一个播放） 前缀
		public static const MONSTER_INTRO_:String = "MI";
		// 开始关卡音效
		public static const BATTLE_INTRO_:String = "BI";
		
		public static const BUILD:String = "build";
		public static const DESELECT:String = "deselect";
		public static const SELECT:String = "select";
		public static const GO:String = "go";

        private static var lastPlaySfxTimeDic : Dictionary = new Dictionary();
		public static function playSfx(s : String) : void
		{
			if (isMute ) return;
            //短时间内只播放一次
            var now :int = getTimer();
            if(lastPlaySfxTimeDic[s] != null)
            {
                if(now - lastPlaySfxTimeDic[s] < 400)
                {
                    trace("SOUND SFX delay");
                    return;
                }
            }
			// 播放
            lastPlaySfxTimeDic[s]=now;
			TDGame.assetsMan.playSound(s);
		}
	}
}
