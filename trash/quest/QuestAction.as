package com.elex.quest
{
	import com.elex.core.elex_internal;
	import com.elex.users.actions.IAction;

	use namespace elex_internal;
	/**
	 * 一个任务保护一个或数个的QuestAction，所有这些action被执行后，任务完成
	 * Example:
	 *    <Action type="BuyAction" count="5" itemId="1005"/>
	 * 
	 * 上面的action表示买一个itemId为1005的东西5次
	 * 说明：IAction有一个属性params,这个属性是会发往后台的,itemId可以是params的直接属性，也可以是其任意子元素的属性
	 * 如BuyAction传给后台的参数为params={item:seedItem,count:5}，虽然params没有属性itemId，但seedItem.itemId是存在的，以此来判断这个action是否匹配。
	 * */
	public class QuestAction
	{
		protected var _type:String;
		protected var _count:uint=1;
		protected var _param:Object={};
		/**
		 *  指定type的action已经完成的次数，当completedCount>=count是，此行为视为完成
		 * */
		elex_internal var completedCount:uint=0;
		
		public function QuestAction()
		{
			
		}
		/**
		 * 要完成的IAction的class名
		 * */
		public function get type():String
		{
			return _type;
		}
		/**
		 * type所代表的action的参数，根据action的设计自由指定
		 * */
		public function get params():Object
		{
			return _param;
		}
		/**
		 * type所代表的action要被执行的次数，执行指定次数，这个action完成
		 * */
		public function get count():uint
		{
			return _count;
		}
		/**
		 * 是否已经完成
		 * */
		public function get  isCompleted():Boolean
		{
			return completedCount>=_count;
		}
		/**
		 * 如果act被执行了，看看这个action是否完成了一个进度
		 * 支持子级属性匹配，比如itemId去匹配item.itemId
		 * */
		public function checkAction(act:IAction):Boolean
		{
			if(isCompleted) return true;
			if(_type!==act.name) return false;
			if(_param!=null){
				for (var key:String in _param){
					if(!matchKeyValue(act.params,key,_param[key])) return false;
				}
			}
			completedCount++;
			trace("完成一项: ",_type,completedCount,"总共需要："+_count);
			return isCompleted;
		}
		/**
		 * target是否有key=value的属性
		 * */
		private function matchKeyValue(target:Object,key:String,value:*):Boolean
		{
			if(target.hasOwnProperty(key)){
				if(target[key]==value) return true;
			}
            for each(var child:* in target){
				if(matchKeyValue(child,key,value)) return true;
			}
			return false;
		}
		/**
		 * 从XML自动解析
		 * */
		public static function parseFromXML(xml:XML):QuestAction
		{
			var action:QuestAction=new QuestAction();
			action._type=xml.@type;
			action._count=parseInt(xml.@count);
			var attrs:XMLList=xml.attributes();
			for each(var attr:XML in attrs){
				var key:String=attr.localName();
				if((key!="type")&&(key!="count")){
					action._param[key]=attr.toString();
				}
			}
			return action;
		}
	}
}