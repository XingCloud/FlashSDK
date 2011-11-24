package com.elex.quest
{
	import com.elex.users.Award;
	
	import flash.display.DisplayObject;

    /**
	 * 任务接口
	 * 说明：任务用XML来进行定义.
	 * 支持的属性包括:id,name,description,type,icon,startTime,endTime,repeatCount,repeatInterval,level,prev,next
	 * 支持的子元素包括: actions,awards
	 * */
	public interface IQuest
	{
		/**
		 * id，唯一标志，必须
		 * */
		function get id():String;
		/**
		 * name
		 * */
		function get name():String;
		/**
		 * 任务描述
		 * */
		function get description():String;
		/**
		 * 类型，自定义
		 * */
		function get type():String;
		
		/**
		 * 任务开始时间，不指定则取决于结束时间，如果无开始和结束时间，这个任务是无时间限制的，采用1970以来的毫秒数
		 * */
		function get startTime():uint;
		/**
		 * 任务结束时间，不指定则从开始时间一直有效，采用1970以来的毫秒数
		 * */
		function get endTime():uint;
		
		/**
		 * 任务可重复次数，默认1次，-1为无限次
		 * */
		function get repeatCount():int;
		/**
		 * 如果是可重复任务，设定重复间隔，如重复间隔为24小时的话，任务便是 每日任务，采用1970以来的毫秒数
		 * */
		function get repeatInterval():uint;
		/**
		 * 此任务的依赖任务的id，如果指定，只有当依赖任务完成后，此任务才能被激活
		 * */
	    function get prev():String;
		/**
		 * 此任务执行完后的下一个任务的id，如果指定，任务完成后，next会被激活
		 * */	
		function get next():String;
		/**
		 * 任务的级别限制,若有其他更多限制的情况，扩展之
		 * */
		function get level():uint;
		/**
		 * icon,任务图标，用于显示，可以是图片地址，元件库中的元件，可选
		 * */
		function get icon():String;
		/**
		 * 如果设定了icon，获取其icon图像
		 * */
		function get iconDisplay():DisplayObject;
		/**
		 * 此任务是否完成，取决于actions里所有的action是否被执行
		 * 元素类型：com.elex.quest.QuestAction
		 * */
		function get actions():Array;
		/**
		 * 任务完成后的奖励
		 * */
		function get award():Award;
		/**
		 * 任务是否可以被领取，取决于起止时间，是否已经完成不能重复，级别是否达到等多方面原因
		 * */
		function get executable():Boolean;
		/**
		 * 任务是否已经完成
		 * */
		function get isCompleted():Boolean;
		/**
		 * 领取任务，领取任务后，任务管理器会监听任务完成状态
		 * */
//		function accept():void;
	}
}