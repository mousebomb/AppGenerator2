/**
 * Created by rhett on 15/1/1.
 */
package td.lobby.view
{

	import org.mousebomb.GameConf;

	import starling.display.Image;
	import starling.display.Sprite;

	public class LoadingUI extends Sprite
	{
		private var loadingImg :Image;
		public function LoadingUI()
		{
			loadingImg = new Image(TDGame.assetsMan.getTexture("UILoading"));
			loadingImg.alignPivot();
			addChild(loadingImg);
			x = GameConf.SIZE_W_IPAD/2;
			y = GameConf.VISIBLE_SIZE_H_MINUS_AD/2;
		}
	}
}
