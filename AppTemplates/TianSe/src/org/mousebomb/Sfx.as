package org.mousebomb
{
	import flash.display.MovieClip;
	/**
	 * @author Mousebomb
	 */
	public class Sfx
	{
		public static var color : MovieClip;
		public static var pic : MovieClip;
		public static var other : OtherSfx;

		public static function init() : void
		{
			color = new Localize.ColorSfx();
			pic = new Localize.PicSfx();
			other = new OtherSfx();
		}
	}
}
