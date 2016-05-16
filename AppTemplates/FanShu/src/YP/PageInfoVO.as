/**
 * Created by rhett on 15/6/28.
 */
package YP
{

	import flash.filesystem.File;

	public class PageInfoVO
	{
		/** 图片文件 png / jpg / swf */
		public var imgFile:File;
		/** 配读音 mp3 若图片为swf，则没有 */
		public var mp3File:File;
		public var order : int ;
	}
}
