package com.elex.quest
{
	import com.elex.core.elex_internal;

	use namespace elex_internal;
	/**
	 * 后台存储Quest的格式，由于前后台有统一的XML定义，所以只存储一些关键数据
	 * 如后台返回一个QuestData={id:"1342",actions:[3,0,0]}
	 *而这个quest的XML定义如下
	 * <quest id="1342">
	 *    <action type="BuyAction" count="5" itemId="1005"/>
	 *    <action type="SellAction" count="2" itemId="1003"/>
	 *    <action type="DestroyAction" count="1" itemId="1006"/>
	 * </quest>
	 * 则表示第一个BuyAction完成了3，后面两个action都没有完成
	 * */
	public class QuestData
	{
		protected var _id:String;
		protected var _actions:Array=[];

		public function QuestData(data:Object)
		{
			try{
				this._id=data.id;
				this._actions=data.actions as Array;
			}catch(e:Error){
				throw new Error("The questData from backend is invalidated!");
			}
		}
		/**
		 * quest的id
		 * */
		public function get id():String
		{
			return _id;
		}
		/**
		 * actioin的完成度
		 * */
		public function get actions():Array
		{
			return _actions;
		}
		/**
		 * 根据后台返回数据，将对应的Quest信息更新
		 * **/
		public function updateQuest():Quest
		{
			var q:Quest;
			q=QuestManager.getQuest(_id);
			if(q==null)  throw new Error(q.id+": the quest does not exist!");
			q.actionsToComplete=[];
			var act:QuestAction;
			for (var i:int=0;i<_actions.length;i++){
				act=q.actions[i];
				act.completedCount=_actions[i];
				trace(act.type+" has completed count: "+act.completedCount);
				if(!act.isCompleted) q.actionsToComplete.push(act);
			}
			return q;
			
		}
	}
}