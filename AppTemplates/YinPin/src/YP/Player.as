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
				if( b ) soundChannel = bgm.play( 0, int.MAX_VALUE );
			} else
			{
			}
		}

		private var _isPaused:Boolean = false;

		public function reset():void
		{
			pausePosition = 0;
			_isPaused = false;
			if( soundChannel ) soundChannel.stop();
			if( curBgmFile ) soundChannel = bgm.play( 0, int.MAX_VALUE );
		}

		public function pausePlay():void
		{
			// 一样 则暂停
			if( _isPaused )
			{
				if( soundChannel ) soundChannel.stop();
				if( curBgmFile ) soundChannel = bgm.play( pausePosition, int.MAX_VALUE );
				_isPaused = false;
			} else
			{
				pausePosition = soundChannel.position;
				if( soundChannel ) soundChannel.stop();
				_isPaused = true;
			}
		}

		private var curBgmFile:String;

		private var pausePosition:Number;
		private var bgm:Sound;
		private var soundChannel:SoundChannel;

	}
}
