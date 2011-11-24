package com.elex.tutorial
{
	import com.elex.core.elex_internal;
	import com.elex.tasks.base.SerialTask;
	import com.elex.users.Award;
	
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;

    use namespace elex_internal;
	/**
	 * Tutorial集合，可以包含很多的Tutorial
	 * */
	[DefaultProperty("tutorials")]
	public class TutorialGroup extends SerialTask
	{
		protected var _id:String;	
		protected var _name:String;
		protected var _description:String="";
//		protected var _tutorials:Array=[];
		protected var _tutorialsMap:Dictionary=new Dictionary();
		
		protected var _award:Award;
		
		/**
		 *跟向导系统相联系的界面或场景
		 */
		public  var target:DisplayObject;

		public function TutorialGroup()
		{
			super();
		}
		public static function parseFromXML(xml:XML):TutorialGroup
		{
			var tg:TutorialGroup=new TutorialGroup();
			tg._id=xml.@tg;
			tg._name=xml.@name;
			tg._description=xml.@description;
			//todo how to do
//			tg._target=xml.@target;
			if(!xml.hasOwnProperty("Tutorials")) throw new Error("TutorialGroup shoud has 'Tutorials' node!");
			var tuList:XMLList=xml.Tutorials[0].children();
			var len:uint=tuList.length();
			var tu:Tutorial;
			for(var i:int=0;i<len;i++){
				tu=Tutorial.parseFromXML(tuList[i]);
				tu.setOwner(tg);
				tg.enqueue(tu,tu.name);
				tg._tutorialsMap[tu.id]=tu;
//				tg._tutorials.push(tu);
			}
			
			if(xml.hasOwnProperty("Award")){
				tg._award=Award.parseFromXML(xml.Award[0]);
			}
			
			return tg;
		}
		public function getTutorial(id:String):Tutorial
		{
			return _tutorialsMap[id];
		}
		/**
		 * 唯一的标志
		 * */
		public function get id():String
		{
			return _id;
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
		public function get award():Award
		{
			return _award;
		}
		/**
		 * 需要执行的一系列tutorial
		 * */
//		public function get tutorials():Array
//		{
//			return _tutorials;
//		}
	}
}