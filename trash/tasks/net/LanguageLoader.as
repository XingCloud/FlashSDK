package com.elex.tasks.net
{
	import com.elex.language.Language;
	
	import flash.events.Event;

	public class LanguageLoader extends XmlLoader
	{
		public function LanguageLoader(urlOrRequest:*)
		{
			super(urlOrRequest);
		}
		override protected function complete():void
		{
			Language.add(this.xml);
			super.complete();
		}
	}
}