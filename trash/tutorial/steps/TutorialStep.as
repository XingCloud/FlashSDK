package com.elex.tutorial.steps
{
	import com.elex.core.Config;
	import com.elex.core.ELEX;
	import com.elex.core.elex_internal;
	import com.elex.tasks.base.Task;
	import com.elex.tasks.net.Remoting;
	import com.elex.tutorial.Tutorial;
	import com.elex.tutorial.TutorialManager;
	import com.elex.tutorial.actions.TutorialStepAction;
	import com.elex.tutorial.tips.AbstractTip;
	import com.elex.tutorial.tips.ITutorialTip;
	import com.elex.users.Award;
	import com.elex.users.actions.IAction;
	
	import flash.display.DisplayObject;
	
	use namespace elex_internal;
	/**
	 * 一个教程步骤，步骤里面可以显示很多的ITutorialTip来提示玩家操作，步骤的要实现的一个很重要的功能是，
	 * 在完成时调用complete()，告诉其父Tutorial这步完成可以进行下步，如ButtonClickStep里面，当某个按钮被玩家点下时，任务就完成了
	 * 同时向后台提交action，获取相应的奖励。
	 * */
	[DefaultProperty("tips")]
	public class TutorialStep extends Task
	{
		protected var _name:String;
		protected var _owner:Tutorial;
		protected var _target:String;
		protected var _award:Award;
		protected var _description:String="";
		protected var _tips:Array=[];
		protected var _index:uint=1;
		
		public function TutorialStep(delay:uint=0)
		{
			super(delay);
		}
		public function parseFromXML(xml:XML):void
		{
			this._name=xml.@name;
			this._description=xml.@description;
			this._target=xml.@target;
			if(!xml.hasOwnProperty("Tips")) throw new Error("TutorialStep shoud has 'Tips' node!");
			var tipList:XMLList=xml.Tips[0].children();
			var len:uint=tipList.length();
			var tipXml:XML;
			var tip:AbstractTip;
			var tipCls:Class;
			for(var i:int=0;i<len;i++){
				tipXml=tipList[i];
				tipCls=TutorialManager.getClass(tipXml.localName().toString());
				if(tipCls==null) throw new Error("The class : "+tipXml.localName().toString()+" does not exist!");
				tip=new tipCls() as AbstractTip;
				tip.parseFromXML(tipXml);
				this._tips.push(tip);
			}
			if(xml.hasOwnProperty("Award")){
				this._award=Award.parseFromXML(xml.Award[0]);
			}
		}
		/**
		 * 记录这是第几步，Tutorial会调用setIndex初始化
		 * */
		public function get index():int
		{
			return _index;
		}
		elex_internal function setIndex(i:uint):void
		{
			_index=i;
		}
		/**
		 * 这个步骤属于哪个Tutorial，初始化时通过setOwner()自动赋值
		 * */
		public function get owner():Tutorial
		{
			return _owner;
		}
		elex_internal function setOwner(owner:Tutorial):void
		{
			_owner=owner;
		}
		override protected function doExecute():void
		{
			if(!validate()) return;
			super.doExecute();
			for each(var tip:ITutorialTip in tips){
				tip.owner=this;
				tip.show();
			}
		}
		override protected function complete():void
		{
			for each(var tip:ITutorialTip in tips){
				tip.hide();
				tip.owner=null;
			}
			tips.splice(0,tips.length);
			if(ELEX.ownerUser){
				//向后台提交
//				ELEX.ownerUser.track(new TutorialStepAction(owner.name,name,_index));
				var amf:Remoting=new Remoting(Config.TUTORIAL_STEP_SERVICE,{user_uid:ELEX.ownerUser.uid,tutorial:this.owner.name,name:this.name,index:this.index});
				amf.execute();
//				if(award) award.submmit();
			}
			super.complete();
		}
		override public function get name():String
		{
			return _name;
		}
		/**
		 * 描述，可能跟多语言有关系，redmine上的管理员可以看到这个描述，知道这步是干什么的
		 * */
		public function get description():String
		{
			return _description;
		}
		/**
		 * 可能有关的界面元素
		 * */
		public function get target():DisplayObject
		{
			if(_target && _target.length){
				if(_owner && _owner.target) return _owner.target[_target] as DisplayObject;
				return null;
				
			}
			return _owner.target;
		}
		/**
		 * 这一步给玩家的视觉提示，比如高亮某个按钮，一步可以有多个tip
		 * 常见的InfoBubble,Highlight
		 * */
		public function get tips():Array
		{
			return _tips;
		}
		/**
		 * 奖励
		 * */
		public function get award():Award
		{
			return _award;
		}
		public function validate():Boolean
		{
			return true;
			//todo
		}
	}
}