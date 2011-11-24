package com.xingcloud.net.loader
{
	import com.xingcloud.language.LanguageManager;
	
	import flash.events.Event;
    /**
	 * 加载语言文件
	 * */
	public class LanguageLoader extends XmlLoader
	{
		public function LanguageLoader(urlOrRequest:*)
		{
			super(urlOrRequest);
		}
		override protected function complete():void
		{
				LanguageManager.languageSource=this.xml;
			super.complete();
		}
	}
}