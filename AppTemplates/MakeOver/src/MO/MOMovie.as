/**
 * Created by rhett on 15/7/11.
 */
package MO
{

	import flash.display.DisplayObject;
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import org.mousebomb.SoundMan;

	import org.mousebomb.interfaces.IDispose;

	/** 交互电影 */
	public class MOMovie extends Sprite implements IDispose
	{
		public var ui:P1_Movie;

		public function MOMovie()
		{
			if( !CONFIG::DESKTOP )
			{
				AoaoBridge.banner(this);
			}
			ui = new P1_Movie();
			addChild( ui );
			ui.skipBtn.addEventListener(MouseEvent.CLICK, nextMode);

			for( var i:int = 0; i < ui.currentLabels.length; i++ )
			{
				var frameLabel:FrameLabel = ui.currentLabels[i];
				if( frameLabel != null )
				{
					// 所有 step1 ~ stepX的 暂停并等待交互
					if( 0 == frameLabel.name.indexOf( "step" ) )
					{
						ui.addFrameScript( frameLabel.frame - 1, enterStep );
					}else if (frameLabel.name == "win")
					{
						// 胜利
						ui.addFrameScript( frameLabel.frame - 1, enterWin );
					}else if (0 == frameLabel.name.indexOf( "ad" ))
					{
						//插屏
						ui.addFrameScript( frameLabel.frame - 1, enterAd );
					}
				}

			}

		}

		private function enterAd():void
		{
			trace("MOMovie/enterAd() inter");
			if( !CONFIG::DESKTOP )
			{
				AoaoBridge.interstitial(this);
			}
			isInterstitialHiddenBanner = true;
		}
		private var isInterstitialHiddenBanner:Boolean = false;

		private function enterWin():void
		{
			ui.stop();
			// 等用户点下一步按钮
			ui.next_btn.addEventListener(MouseEvent.CLICK, nextMode);
		}

		/** 下一模式 */
		private function nextMode( event:MouseEvent ):void
		{
			SoundMan.playSfx(SoundMan.BTN);
			Game.instance.replaceScene( new MODecorate() );
		}

		private function enterStep():void
		{
			ui.stop();
			collectTotal=collected=0;
			for( var i:int = ui.numChildren - 1; i >= 0; i-- )
			{
				var child:DisplayObject = ui.getChildAt( i );
				if( child.name == "next_btn" || child.name == "c" )
				{
					//所有 next_btn 单击1个继续播
					child.addEventListener(MouseEvent.MOUSE_DOWN,clickNext);
				}else if ( child.name.indexOf("race_")==0 )
				{
					// 所有 race_%i% 单击过所有才继续播
//					var id : int = parseInt(child.name.substr(5));
					var mc :MovieClip = child as MovieClip;
					mc.stop();
					mc.addEventListener(MouseEvent.MOUSE_DOWN , collectNext);
					collectTotal++;
				}
			}
		}

		private function collectNext( event:MouseEvent ):void
		{
			var mc :MovieClip = event.currentTarget as MovieClip;
			mc.removeEventListener(MouseEvent.MOUSE_DOWN , collectNext);
			mc.addFrameScript(mc.totalFrames-1 , function():void{collectAnimateComplete(mc);});
			mc.play();
		}

		private function collectAnimateComplete(mc:MovieClip):void
		{
			mc.stop();
			if(++collected >= collectTotal )
			{
				collectTotal=collected=0;
				ui.play();
			}
		}
		private var collectTotal : int = 0;
		private var collected : int = 0;

		private function clickNext( event:MouseEvent ):void
		{
			SoundMan.playSfx(SoundMan.BTN);
			ui.play();

			if(isInterstitialHiddenBanner)
			{
				trace("MOMovie/clickNext() bnr");
				isInterstitialHiddenBanner = false;
                if( !CONFIG::DESKTOP )
                {
                    AoaoBridge.banner(this);
                }
            }
		}

		public function dispose():void
		{
		}
	}
}
