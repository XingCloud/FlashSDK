package com.xingcloud.services
{
	import com.xingcloud.core.xingcloud_internal;
	import com.xingcloud.tasks.SerialTask;
	import com.xingcloud.tasks.Task;
	import com.xingcloud.tasks.TaskEvent;
	import flash.events.EventDispatcher;

	use namespace xingcloud_internal;

	/**
	 * 登录成功时进行派发。
	 * @eventType com.xingcloud.event.ServiceEvent
	 */
	[Event(name="login_success", type="com.xingcloud.event.ServiceEvent")]
	/**
	 * 登录失败时进行派发。
	 * @eventType com.xingcloud.event.ServiceEvent
	 */
	[Event(name="login_error", type="com.xingcloud.event.ServiceEvent")]
	/**
	 *注册成功时进行派发。
	 * @eventType com.xingcloud.event.ServiceEvent
	 */
	[Event(name="register_success", type="com.xingcloud.event.ServiceEvent")]
	/**
	 *注册失败时进行派发。
	 * @eventType com.xingcloud.event.ServiceEvent
	 */
	[Event(name="register_error", type="com.xingcloud.event.ServiceEvent")]
	/**
	 *获取用户信息成功
	 * @eventType com.xingcloud.event.ServiceEvent
	 */
	[Event(name="get_profile_success", type="com.xingcloud.event.ServiceEvent")]
	/**
	 *获取用户信息失败
	 * @eventType com.xingcloud.event.ServiceEvent
	 */
	[Event(name="get_profile_error", type="com.xingcloud.event.ServiceEvent")]
	/**
	 *获取用户物品成功
	 * @eventType com.xingcloud.event.ServiceEvent
	 */
	[Event(name="item_load_success", type="com.xingcloud.event.ServiceEvent")]
	/**
	 *获取用户物品失败
	 * @eventType com.xingcloud.event.ServiceEvent
	 */
	[Event(name="item_load_error", type="com.xingcloud.event.ServiceEvent")]
	/**
	 * 服务调用成功
	 * @eventType com.xingcloud.event.ServiceEvent
	 */
	[Event(name="service_complete", type="com.xingcloud.event.ServiceEvent")]
	/**
	 * 服务调用失败
	 * @eventType com.xingcloud.event.ServiceEvent
	 */
	[Event(name="service_error", type="com.xingcloud.event.ServiceEvent")]
	/**
	 * 服务调用进度
	 * @eventType com.xingcloud.event.ServiceEvent
	 */
	[Event(name="service_progress", type="com.xingcloud.event.ServiceEvent")]
	/**
	 * 服务管理器，用于调用行云所提供的服务
	 *
	 */
	public class ServiceManager extends EventDispatcher
	{
		private static var _instance:ServiceManager;

		/**
		 * 获取服务管理器实例
		 * @return 服务管理器实例
		 *
		 */
		public static function get instance():ServiceManager
		{
			if (_instance == null)
			{
				_instance=new ServiceManager(new lock);

			}
			return _instance;
		}

		/**
		 * 服务管理器，用于添加和加载服务
		 * 不可直接在外部被实例化
		 */
		public function ServiceManager(lock:lock)
		{
			_taskQueue=new SerialTask();
		}

		private var _services:Array;
		private var _taskQueue:SerialTask;

		/**
		 *增加一个服务，服务会按照添加次序顺序执行
		 * @param s 服务
		 *
		 */
		public function addService(s:IService):Task
		{
			_taskQueue.enqueue(s.executor);
			return s.executor;
		}

		/**
		 *获取任务队列，以便和其他任务共同执行
		 * @return 服务任务队列
		 *
		 */
		public function get taskQueue():Task
		{
			return _taskQueue;
		}

		/**
		 *开始加载服务
		 *
		 */
		public function start():void
		{
			_taskQueue.execute();
			_taskQueue=new SerialTask();
		}

		/**
		 *请求一个服务
		 * @param s 服务实例
		 *
		 */
		public function send(s:IService):void
		{
			s.executor.execute();
		}
	}
}

internal class lock
{
}
