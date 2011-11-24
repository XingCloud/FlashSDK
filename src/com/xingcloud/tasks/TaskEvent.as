package com.xingcloud.tasks
{
	import flash.events.Event;

	/**
	 *任务执行中派发的一系列事件,用于表示任务执行的各种状态.
	 *
	 */
	public class TaskEvent extends Event
	{
		////////////////////////////////////////////////////////////////////////////////////////
		// Constants                                                                          //
		////////////////////////////////////////////////////////////////////////////////////////

		/**
		 * 任务执行完毕
		 */
		public static const TASK_COMPLETE:String="task_complete";

		/**
		 *任务执行进程
		 */
		public static const TASK_PROGRESS:String="task_progress";

//		/**
//		 *放弃任务执行
//		 */
//		public static const TASK_ABORT:String		= "task_abort";

		/**
		 *任务执行失败
		 */
		public static const TASK_ERROR:String="task_error";
		/**
		 *重试任务
		 */
		public static const TASK_RETYR:String="task_retry";

		////////////////////////////////////////////////////////////////////////////////////////
		// Public Methods                                                                     //
		////////////////////////////////////////////////////////////////////////////////////////

		/**
		 *创建一个任务事件的事例
		 * @param type 事件类型
		 * @param task 当前事件的引用
		 *
		 */
		public function TaskEvent(type:String, task:Task)
		{
			super(type);
			_task=task;
		}

		////////////////////////////////////////////////////////////////////////////////////////
		// Properties                                                                         //
		////////////////////////////////////////////////////////////////////////////////////////

		/** @private */
		protected var _task:Task;

		/**
		 *
		 * @inheritDoc
		 *
		 */
		override public function clone():Event
		{
			return new TaskEvent(type, _task);
		}


		////////////////////////////////////////////////////////////////////////////////////////
		// Getters & Setters                                                                  //
		////////////////////////////////////////////////////////////////////////////////////////

		/**
		 * 派发此事件的任务
		 */
		public function get task():Task
		{
			return _task;
		}
	}
}
