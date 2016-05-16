package hdsj
{

	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;

	import org.mousebomb.utils.btrace;

	/**
	 * @author Mousebomb
	 */
	public class TimuService
	{
		private var urlL : URLLoader ;
		private var urlR : URLRequest;

		public function TimuService()
		{
		}

		public function loadTimu() : void
		{
			urlR = new URLRequest("timu");
			urlL = new URLLoader(urlR);
			urlL.dataFormat = URLLoaderDataFormat.TEXT;
			urlL.addEventListener(Event.COMPLETE, onComplete);
		}

		public var timuModel : TimuModel;

		private function onComplete(event : Event) : void
		{
			var txt : String = urlL.data;
			txt=txt.replace(" \n","\n");
			txt=txt.replace("\n ","\n");
			var timus : Array = txt.split("\n\n");
			for (var i : int = 0; i < timus.length; i++)
			{
				var timuLi : String = timus[i];
				var question : QuestionVO = new QuestionVO();
				var timuLines :Array = timuLi.split("\n");
				question.question=timuLines.shift();
				question.rightAns = timuLines[0];
				question.allAwnsers =timuLines;
				var l :int =question.allAwnsers.length;
				if(l!=2){
				btrace("题目解析",i);
				btrace("非法的题目选项数目：",l);
				trace('question: ' + (question.question));
				trace('question.allAwnsers: '+l+":" + (question.allAwnsers));
				//throw new Error("非法的题目选项数目："+l+(":题目"+question.question + "\n 选项：") +  (question.allAwnsers));
				}else{
					timuModel.addTimu(question);
				}
			}
			
			//随机一个题目池子
			timuModel.randomize();
		}
	}
}
