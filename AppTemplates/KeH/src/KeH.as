/**
 * Created by rhett on 16/5/15.
 */
package {

import flash.display.Loader;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;

public class KeH extends Sprite
{
	[Embed(source="../EmbedContent.swf", mimeType="application/octet-stream")]
	private static const EmbedContent:Class;

	private var contentLoader:Loader;
	public function KeH()
	{
		super();
		if(this.stage)
		{
			onStage();
		}else{
			addEventListener(Event.ADDED_TO_STAGE, onStage);
		}
		contentLoader = new Loader();
		var ctx :LoaderContext = new LoaderContext(false,ApplicationDomain.currentDomain);
		ctx.allowCodeImport = true;
		contentLoader.loadBytes( new EmbedContent() ,ctx);
		addChild(contentLoader);

	}

	private function onStage( event:Event = null ):void
	{
		stage.align = StageAlign.TOP_LEFT;
		stage.scaleMode=StageScaleMode.NO_SCALE;
		trace(stage.fullScreenWidth+"x"+stage.fullScreenHeight );
		scaleX = stage.fullScreenWidth/ ${gameW} ;
		scaleY = stage.fullScreenHeight/ ${gameH};
	}
}
}
