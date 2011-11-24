package com.xingcloud.net.loader
{
	import com.xingcloud.language.LanguageManager;
	import flash.events.Event;
    /**
	 * 加载语言样式
	 * */
	public class LanguageStyleLoader extends CSSLoader
	{
		public function LanguageStyleLoader(urlOrRequest:*)
		{
			super(urlOrRequest);
		}
		override protected function onLoadComplete(event:Event):void
		{
				this._styleSheet.parseCSS(this._loader.data);
				LanguageManager.styleSheet=this._styleSheet;
			super.onLoadComplete(event);
		}
	}
}