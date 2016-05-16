/**
 * Created by rhett on 15/6/13.
 */
package YP
{

	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;

	public class Player
	{

				private static var _instance : Player;

				public static function getInstance() : Player
				{
					if (_instance == null)
							_instance = new Player();
					return _instance;
				}

				public function Player()
				{
					if (_instance != null)
						throw new Error('singleton');
				}


		public function play( b:String ):void
		{

			if( bgm == null )
			{
				bgm = new Sound();
			}
			if( b != curBgmFile )
			{
				curBgmFile = b;
				try
				{
					bgm.close();
				} catch( e:* )
				{
					bgm = new Sound();
				}
				if( b ) bgm.load( new URLRequest( b ) );
				if( soundChannel ) soundChannel.stop();
				if( b ) soundChannel = bgm.play( 0, 1 );
			} else
			{
			}
		}


		public function reset():void
		{
			pausePosition = 0;
			if( soundChannel ) soundChannel.stop();
			if( curBgmFile ) soundChannel = bgm.play( 0, 1 );
		}

		public function stop():void
		{
			if( soundChannel ) soundChannel.stop();
			if(bgm)
			{
				try
				{
					bgm.close();
				} catch( e:* )
				{
				}
			}
			curBgmFile = "";
		}

		private var curBgmFile:String;

		private var pausePosition:Number;
		private var bgm:Sound;
		private var soundChannel:SoundChannel;

	}
}
