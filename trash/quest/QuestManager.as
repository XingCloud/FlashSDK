package com.elex.quest
{
	import com.elex.users.actions.ActionResult;
	
	import flash.utils.Dictionary;

	public class QuestManager
	{
		protected static var _groups:Dictionary;
		
		public function QuestManager()
		{
		}
		/***
		 * 添加一个XML定义的任务列表，允许多个xml文件，但要保持各个节点的id唯一，典型的XML定义如下
		 * <tns:quests xmlns:tns=" http://www.iw.com/sns/platform/" xmlns:xsi=" http://www.w3.org/2001/XMLSchema-instance">
			 * <Group id="2001"/>
			 *    <Quest id="1342">
			 *       <Action type="BuyAction" count="5" itemId="1005"/>
			 *       <Action type="SellAction" count="2" itemId="1003"/>
			 *       <Action type="DestroyAction" count="1" itemId="1006"/>
			 *    </Quest>
			 *    <Quest id="1343">
			 *       <Action type="BuyAction" count="5" itemId="1005"/>
			 *       <Action type="SellAction" count="2" itemId="1003"/>
			 *       <Action type="DestroyAction" count="1" itemId="1006"/>
			 *    </Quest>
			 * 	  <Group id="2002"/>
			 *       <Quest id="1344">
			 *          <Action type="BuyAction" count="5" itemId="1005"/>
			 *          <Action type="SellAction" count="2" itemId="1003"/>
			 *          <Action type="DestroyAction" count="1" itemId="1006"/>
			 *       </Quest>
			 *     </Group>
			 * </Group>
			 * <Group id="2003"/>
			 *     <Quest id="1345">
			 *        <Action type="BuyAction" count="5" itemId="1005"/>
			 *        <Action type="SellAction" count="2" itemId="1003"/>
			 *        <Action type="DestroyAction" count="1" itemId="1006"/>
			 *     </Quest>
			 * </Group>
		 *  </tns:quests>
		 * */
		public static function addXmlDefinition(xml:XML):void
		{
			if(_groups==null) _groups=new Dictionary();
			var children:XMLList=xml.children();
			var group:QuestGroup;
			for each(var childXml:XML in children){
				group=QuestGroup.parseFromXML(childXml);
				_groups[group.id]=group;
			}
		}
		/**
		 * 获取某个id的quest,onlyAcceptable=true只找到用户能执行的任务，比如时间是否过期，用户级别是否满足要求，等等
		 * */
		public static function getQuest(id:String,onlyAcceptable:Boolean=true):Quest
		{
			var quest:Quest;
			for each(var g:QuestGroup in _groups){
				quest=g.getQuest(id,true);
				if(quest){
					if(!onlyAcceptable) return quest;
					if(quest.executable) return quest;
				}
			}
			return quest;
		}
		public static function getGroup(id:String,deepSearch:Boolean=false):QuestGroup
		{
			var group:QuestGroup=_groups[id];
			if(group) return group;
			for each(var g:QuestGroup in _groups){
				group=g.getGroup(id,true);
				if(group) return group;
			}
			return group;
		}
		public  static function get groups():Dictionary
		{
			return _groups;
		}
		public static function handleDataFromServer(data:Object):void
		{
			var result:ActionResult=ActionResult.parseFromObj(data);
			if(result.success){
				for each(var qd0:* in result.data.actived){
					new QuestData(qd0).updateQuest();
				}
			}else{
				//handle the error
				trace("QeustManager=>handleDataFromServer: "+result.message);
			}
		}
	}
}