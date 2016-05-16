package org.mousebomb
{
	import flash.media.SoundChannel;
	import flash.media.Sound;
	import flash.net.URLRequest;

	/**
	 * @author Mousebomb
	 */
	public class SoundMan
	{
		private static var other : OtherSfx;
		private static var _isMute : Boolean = false;

		public static function init() : void
		{
			other = new OtherSfx();
			other.stop();
		}

		/**  */
		public static const WRONG : String = "WRONG";
		/**  */
		public static const RIGHT : String = "RIGHT";
		/**  */
		public static const BTN : String = "BTN";
		/**  */
		public static const GO : String = "GO";
		/**  */
		public static const FINISH : String = "FINISH";
		/**  */
		public static const PRIZE : String = "PRIZE";

		public static function playSfx(s : String) : void
		{
			if (isMute ) return;
			other.gotoAndStop(1);
			other.gotoAndStop(s);
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
                    bgm = new Sound();
				}
				if(b) bgm.load(new URLRequest(b));
			}
			if (soundChannel) soundChannel.stop();
			if(b) soundChannel = bgm.play(0, int.MAX_VALUE);
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
				playBgm(SoundMan.curBgmFile);
			}
		}
	}
}
