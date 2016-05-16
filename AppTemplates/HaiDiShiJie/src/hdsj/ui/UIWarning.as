/**
 * Created by rhett on 16/2/17.
 */
package hdsj.ui
{

	import com.greensock.TweenLite;

	import flash.display.Sprite;

	import hdsj.ui.UIWarning;

	import org.mousebomb.GameConf;

	import ui.Warning;

	public class UIWarning extends Sprite
	{


		private var _ui:Warning;
		public function UIWarning(prompt:String)
		{
			super();
			_ui =new Warning();
			addChild(_ui);
			_ui.tf.text = prompt;
			TweenLite.to(_ui ,3,{y:-100,onComplete:onTweenComp});
		}

		private function onTweenComp():void
		{
			this.parent.removeChild(this);

		}

	}
}
