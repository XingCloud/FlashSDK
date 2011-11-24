package com.elex.quest
{
	import com.elex.core.Config;
	import com.elex.core.ELEX;
	import com.elex.core.ElexEvent;
	import com.elex.core.elex_internal;
	import com.elex.tasks.base.Task;
	import com.elex.tasks.net.Remoting;
	import com.elex.users.Award;
	import com.elex.users.actions.IAction;
	
	import flash.display.DisplayObject;
	import flash.events.Event;

    use namespace elex_internal
	/**
	 * var quest:Quest;
	 * if(quest.executable) quest.execute();
	 * 典型的XML定义
	 * <Quest id="1342">
	 *   <Actions>
	 *      <Action type="BuyAction" count="5" itemId="1005"/>
	 *      <Action type="SellAction" count="2" itemId="1003"/>
	 *      <Action type="DestroyAction" count="1" itemId="1006"/>
	 *   </Actions>
	 *   <Award exp="50" coins="200" itemType="CropItem" itemCount="5"/>
	 * </Quest>
	 * todo,Quest和后台的交流结果，尤其是失败的时候，是否应该统一交给QuestManager来管理？
	 * QuestManager要成为所有Quest操作的唯一入口。。。
	 * */
	public class Quest extends Task implements IQuest
	{
		public function Quest()
		{
			super();
		}
		override protected function doExecute():void
		{
			super.doExecute();
			var amf:Remoting=new Remoting(Config.QUEST_ACCEPT_SERVICE,{user_uid:ELEX.ownerUser.uid,quest_uid:this.id});
			amf.onSuccess=this.onAcceptSuccess;
			amf.onFail=this.onAcceptFail;
			amf.execute();	
			ELEX.ownerUser.addEventListener(ElexEvent.ACTION_TRACKING,checkAction);
		}
		override protected function notifyError(errorMsg:String):void
		{
			super.notifyError(errorMsg);
			ELEX.ownerUser.removeEventListener(ElexEvent.ACTION_TRACKING,checkAction);
		}
		override protected function complete():void
		{
			super.complete();
			ELEX.ownerUser.removeEventListener(ElexEvent.ACTION_TRACKING,checkAction);
		}
		/**
		 * 没有完成的actions
		 * */
		elex_internal var actionsToComplete:Array=[];
		public static function parseFromXML(xml:XML):Quest
		{
			var q:Quest=new Quest();
			q._id=xml.@id;
			q._name=xml.@name;
			q._description=xml.@description;
			q._type=xml.@type;
			q._startTime=parseInt(xml.@startTime);
			q._endTime=parseInt(xml.@endTime);
			q._repeatCount=parseInt(xml.@repeatCount);
			q._repeatInterval=parseInt(xml.@repeatInterval);
			q._level=parseInt(xml.@level);
			q._icon=xml.@icon;
			q._prev=xml.@prev;
			q._next=xml.@next;
			q._actions=[];
			
			var act:QuestAction;
			var actionList:XMLList=xml.Actions.children();
			var len:uint=actionList.length();
			for(var i:int=0;i<len;i++){
				act=QuestAction.parseFromXML(actionList[i]);
				q._actions.push(act);
			}
			if(xml.hasOwnProperty("Award")){
				q._award=Award.parseFromXML(xml.Award[0]);
			}
			q.actionsToComplete=q._actions.concat();
			return q;
		}
		protected var _id:String;
		public function get id():String
		{
			return _id;
		}
		protected var _name:String;
		override public function get name():String
		{
			return _name;
		}
		protected var _description:String;
		public function get description():String
		{
			return _description;
		}
		protected var _type:String;
		public function get type():String
		{
			return _type;
		}
		protected var _startTime:uint;
		public function get startTime():uint
		{
			return _startTime;
		}
		protected var _endTime:uint;
		public function get endTime():uint
		{
			return _endTime;
		}
		protected var _repeatCount:int;
		public function get repeatCount():int
		{
			return _repeatCount;
		}
		protected var _repeatInterval:uint;
		public function get repeatInterval():uint
		{
			return _repeatInterval;
		}
		protected var _prev:String;
		public function get prev():String
		{
			return _prev;
		}
		protected var _next:String;
		public function get next():String
		{
			return _next;
		}
		protected var _level:uint=0;
		public function get level():uint
		{
			return _level;
		}
		protected var _icon:String;
		public function get icon():String
		{
			return _icon;
		}
		protected var _iconDisplay:DisplayObject;
		public function get iconDisplay():DisplayObject
		{
			//todo....
			return _iconDisplay;
		}
		protected var _actions:Array=[];
		public function get actions():Array
		{
			return _actions;
		}
		protected var _award:Award;
		public function get award():Award
		{
			return _award;
		}
		public function get executable():Boolean
		{
			//todo
			//起止时间，重复情况，level情况，prev是否完成？
			var canExecute:Boolean=!this.isCompleted;
			return canExecute;
		}
		override public function get isCompleted():Boolean
		{
			return actionsToComplete.length==0;
		}	
		/**
		 * 如果用户产生了一个action，那么更新下此任务的完成度
		 * todo，这里有问题
		 * */
		protected function checkAction(event:ElexEvent):void
		{
			var completed:Boolean=true;
			var act:IAction;
			var actOk:Boolean;
			var acts:Array=actionsToComplete.concat();
			for each(var qact:QuestAction in acts){
				act=event.data as IAction;
				actOk=qact.checkAction(act);
				if(actOk) {
					trace("******行为完成一个："+act.name);
					var i:int=actionsToComplete.indexOf(qact);
					if(i>-1) actionsToComplete.splice(i,1);
				}
				
				if(!actOk) completed=false;
			}
			if(completed){
				trace("******任务完成一个："+this.name);
				this.complete();
				var amf:Remoting=new Remoting(Config.QUEST_SUBMMIT_SERVICE,{user_uid:ELEX.ownerUser.uid,quest_uid:this.id});
				amf.onSuccess=this.onSubmmitSuccess;
				amf.onFail=this.onSubmmitFail;
				amf.execute();	
				//奖励
				if(_award){
//					_award.submmit(new QuestChangeAction(this.id,"complete"),true);
				}
				//自动激活？
//				if(this.next){
//					var quest:Quest=QuestManager.getQuest(next);
//					if(quest&&quest.executable) quest.execute();
//				}
			}
		}
		private function onAcceptSuccess(data:Object):void
		{
			trace("任务接受成功！");
		}
		private function onAcceptFail(error:String):void
		{
			trace("任务接受失败: "+error);
		}
		private function onSubmmitSuccess(data:Object):void
		{
			trace("任务完成提交成功！");
		}
		private function onSubmmitFail(error:String):void
		{
			trace("任务完成提交失败: "+error);
		}
		
	}
}