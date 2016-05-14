/**
 * Created by rhett on 15/6/7.
 */
package
{

	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.media.SoundMixer;
	import flash.system.ApplicationDomain;
	import flash.utils.clearInterval;
	import flash.utils.getDefinitionByName;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;

	/*
	 * USAGE:
	 *
	 * AoaoBridge.gengDuo(this);
	 * AoaoBridge.interstitial(this);
	 * AoaoBridge.banner(this);
	 * .visible = AoaoBridge.isMoreBtnVisible;
	 * */
	public class AoaoBridge
	{
		public function AoaoBridge()
		{
		}

		public static function gengDuo( d:EventDispatcher ):void
		{
			d.dispatchEvent( new Event( "GENG_DUO", true ) );
		}

		public static function interstitial( d:EventDispatcher ):void
		{
			d.dispatchEvent( new Event( "INTERSTITIAL", true ) );

		}

		public static function banner( d:EventDispatcher ):void
		{
			d.dispatchEvent( new Event( "BANNER", true ) );

		}


		public static function  get isMoreBtnVisible():Boolean
		{

			// more
			if( ApplicationDomain.currentDomain.hasDefinition( "com.aoaogame.sdk.adManager.MyAdManager" ) )
			{
				var MyAdManager = getDefinitionByName( "com.aoaogame.sdk.adManager.MyAdManager" ) as Class;
				return MyAdManager.showMoreBtn;
			} else
			{
				return false;
			}
		}

		public static function saveScreen( w:int, h:int, display:DisplayObject ):void
		{
			var CameraRoll:Class = getDefinitionByName( "flash.media.CameraRoll" ) as Class;
			if( CameraRoll && CameraRoll.supportsAddBitmapData )
			{
				var croll = new CameraRoll();
				var bmd:BitmapData = new BitmapData( w, h, false, 0xffffffff );
				bmd.draw( display );
				croll.addBitmapData( bmd );
			}
			//
			if( whiteFlash == null )
			{
				whiteFlash = new Shape();
				whiteFlash.graphics.beginFill( 0xffffff, 1 );
				whiteFlash.graphics.drawRect( 0, 0, w, h );
				whiteFlash.graphics.endFill();
			}
			whiteFlash.width = w;
			whiteFlash.height = h;
			whiteFlash.alpha = 1.0;
			if( display is Stage )
			{
				(display as Stage).addChild( whiteFlash );
			} else if( display is DisplayObjectContainer )
			{
				DisplayObjectContainer( display ).addChild( whiteFlash );
			} else
			{
				DisplayObjectContainer( display.parent ).addChild( whiteFlash );
			}
			clearInterval(flashHideInterval);
			flashHideInterval = setInterval(hideFlash,50);
		}

		private static function hideFlash():void
		{
			whiteFlash.alpha -= .1;
			if(whiteFlash.alpha <=0.0)
			{
				if( whiteFlash.parent ) whiteFlash.parent.removeChild( whiteFlash );
				clearInterval(flashHideInterval);
			}
		}


		private static var whiteFlash:Shape;
		private static var flashHideInterval : uint ;
	}
}
