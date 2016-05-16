/**
 * Created by rhett on 14/12/25.
 */
package td.util
{

	import flash.display.BitmapData;
	import flash.display.Loader;

	import starling.textures.Texture;

	import org.mousebomb.loader.JYLoader;

	public class ImageDataModel
	{

				private static var _instance : ImageDataModel;

				public static function getInstance() : ImageDataModel
				{
					if (_instance == null)
							_instance = new ImageDataModel();
					return _instance;
				}

				public function ImageDataModel()
				{
					if (_instance != null)
						throw new Error('singleton');
				}


		/**
		 * 加载图片
		 */
		public function loadImageToAssets(url :String , name : String ):void
		{
			JYLoader.getInstance().reqResource(url,JYLoader.RES_BITMAP, 1,
				function(url_:String ,data :BitmapData,mark:*):void{
					TDGame.assetsMan.addTexture(name , Texture.fromBitmapData(data));
					JYLoader.getInstance().markAsNocache(url);
				}
			);
		}

		/**
		 * 设置任务全部加载完成回调 无参数 (只生效一次)
		 */
		public function set onComplete(f:Function):void
		{
			JYLoader.getInstance().addAllLoadCompleteCallback(f);
		}

	}
}
