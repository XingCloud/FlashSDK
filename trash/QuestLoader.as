package com.xingcloud.net.loader
{
//	import com.elex.quest.QuestManager;

	/**
	 * 加载游戏任务xml
	 * */
	public class QuestLoader extends XmlLoader
	{
		public function QuestLoader(urlOrRequest:*)
		{
			super(urlOrRequest);
		}
		override protected function complete():void
		{
//			QuestManager.addXmlDefinition(this.xml);
			super.complete();
		}
	}
}