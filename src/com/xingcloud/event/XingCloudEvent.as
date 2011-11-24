package com.xingcloud.event
{
	import com.xingcloud.tasks.CompositeTask;
	import com.xingcloud.tasks.Task;
	import flash.events.Event;

	public class XingCloudEvent extends Event
	{
		/**
		 *行云初始化完毕，包括社交平台对接,配置加载
		 */
		public static const INIT_SUCCESS:String="init_success";
		/**
		 *行云初始化失败
		 */
		public static const INIT_ERROR:String="init_error";
		/**
		 *行云初始化进度
		 */
		public static const INIT_PROGRESS:String="init_progress";

		/**
		 *实例化一个行云事件
		 * @param type 事件类型
		 * @param task 发生事件的相关命令
		 * @param bubbles 是否冒泡
		 * @param cancelable 是否可以取消
		 *
		 */
		public function XingCloudEvent(type:String,
			data:Object,
			message:String="",
			bubbles:Boolean=false,
			cancelable:Boolean=false)
		{
			_data=data;
			_message=message;
			super(type, bubbles, cancelable);
		}

		private var _data:Object;
		private var _message:String;

		public function get data():Object
		{
			return _data;
		}

		public function get message():String
		{
			return _message;
		}

		override public function clone():Event
		{
			return new XingCloudEvent(this.type, this.data, _message, this.bubbles, this.cancelable);
		}
	}
}
