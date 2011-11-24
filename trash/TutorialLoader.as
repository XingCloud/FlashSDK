package com.xingcloud.net.loader
{
//	import com.elex.tutorial.TutorialManager;

	public class TutorialLoader extends XmlLoader
	{
		public function TutorialLoader(urlOrRequest:*)
		{
			super(urlOrRequest);
		}
		override protected function complete():void
		{
//			TutorialManager.addXmlDefinition(this.xml);
			super.complete();
		}
	}
}