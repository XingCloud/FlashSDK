package com.xingcloud.tasks
{

	/**
	 * 复合任务类.用于将多个任务进行组合,并按照一定的顺序进行执行.
	 * 复合任务无论其子任务执行是否成功，在所有任务完成执行后，都会派发<code>TaskEvent.TASK_COMPLETE</code>事件，
	 * 如果有任务执行失败，则可通过访问failTasks来获取执行失败的任务。
	 */
	public class CompositeTask extends Task
	{
		////////////////////////////////////////////////////////////////////////////////////////
		// Public Methods                   								                //
		////////////////////////////////////////////////////////////////////////////////////////
		/**
		 *请继承此复合任务类来实现具体的复合任务逻辑，此类无法被直接实例化。
		 * @param delay 延迟执行时间
		 * @param timeOut 超时时间
		 * @param retryCount 重试次数
		 *
		 */
		public function CompositeTask(delay:uint=0, timeOut:uint=999999, retryCount:uint=0)
		{
			super(delay, timeOut, retryCount);
			_tasks=[];
			_exeQueue=[];
			_failTasks=[];
			_itemsTotal=0;
			_itemsComplete=0;
			_errorCount=0;
		}

		////////////////////////////////////////////////////////////////////////////////////////
		// Properties            									                         //
		////////////////////////////////////////////////////////////////////////////////////////
		/**
		 *是否在有错误发生时立即派发<code>TaskEvent.TASK_ERROR</code>事件进行通知，错误事件中包括出错的任务引用。
		 * 最终的<code>TaskEvent.TASK_COMPLETE</code>事件派发后也可以获取所有执行失败的任务，但如果要在错误发生时即
		 * 进行处理，则打开此模式。
		 * @default false
		 */
		public var errorImmediateNotify:Boolean;

		/** @private */
		protected var _errorCount:int;
		/** @private*/
		protected var _exeQueue:Array; //实际执行的队列
		protected var _failTasks:Array; //失败的队列

		/** @private */
		protected var _itemsComplete:int;
		/** @private */
		protected var _itemsTotal:int;
		/** @private */
		protected var _tasks:Array;

		/**
		 *增加任务
		 * @param task 新增的任务
		 */
		public function enqueue(task:Task):Task
		{
			if (_tasks.indexOf(task) == -1)
			{
				_tasks.push(task);
				_exeQueue.push(task);
				_itemsTotal++;
			}
			return task;
		}

		////////////////////////////////////////////////////////////////////////////////////////
		// Getters & Setters                                                                  //
		////////////////////////////////////////////////////////////////////////////////////////

		/**
		 * 失败的任务列表
		 */
		public function get failTasks():Array
		{
			return _failTasks;
		}

		/**
		 * 已完成的项目数
		 */
		public function get itemsComplete():int
		{
			return _itemsComplete;
		}

		/**
		 *总项目数
		 */
		public function get itemsTotal():int
		{
			return _itemsTotal;
		}



		/**
		 *在个数上的完成比率
		 */
		public function get ratio():Number
		{
			if (_itemsTotal != 0)
				return _itemsComplete / _itemsTotal;
			else
				return 0;
		}

		/**
		 * 为子任务添加监听
		 * @private
		 *
		 */
		protected function addTaskListeners(cmd:Task):void
		{
			cmd.addEventListener(TaskEvent.TASK_COMPLETE, onTaskComplete);
			cmd.addEventListener(TaskEvent.TASK_ERROR, onTaskError);
			cmd.addEventListener(TaskEvent.TASK_PROGRESS, onTaskProgress);
		}

		/**
		 *计算总完成量
		 * @private
		 */
		protected function countComplete():void
		{
			for each (var t:Task in _tasks)
			{
				_completeNum+=t.completeNum;
			}
		}

		/**
		 * 计算总量
		 *@private
		 */
		protected function countTotal():void
		{
			for each (var t:Task in _tasks)
			{
				_totalNum+=t.totalNum;
			}
		}

		////////////////////////////////////////////////////////////////////////////////////////
		// Override Method                                                                  //
		////////////////////////////////////////////////////////////////////////////////////////

		/**
		 * @inheritDoc
		 */
		override protected function doExecute():void
		{
			super.doExecute();
			countTotal();
			next();
		}


		////////////////////////////////////////////////////////////////////////////////////////
		// Protected Methods                                                                 //
		////////////////////////////////////////////////////////////////////////////////////////

		/**
		 *是否需要继续执行
		 * @return 仍有任务需要执行返回<code>true</code>,没有则返回<code>false</code>
		 *
		 */
		protected function next():Boolean
		{
			return _exeQueue.length != 0;
		}

		/**
		 *
		 * 子任务执行成功
		 *
		 */
		protected function onTaskComplete(e:TaskEvent):void
		{
			removeTaskListeners(e.task);
			_itemsComplete++;
			if (!next())
			{
				notifyComplete(this);
			}
		}

		/**
		 *子任务执行失败
		 *
		 */
		protected function onTaskError(e:TaskEvent):void
		{
			_errorCount++;
			_itemsComplete++;
			removeTaskListeners(e.task);
			_failTasks.push(e.task);
			if (errorImmediateNotify) //立马通知
			{
				dispatchEvent(e.clone());
			}
			if (!next())
			{
				notifyComplete(this);
			}
		}

		/**
		 *子任务执行进程响应
		 *
		 */
		protected function onTaskProgress(e:TaskEvent):void
		{
			countComplete(); //计算总完成量
			countTotal(); //计算总量
			notifyProgress(this);
		}

		/**
		 * 为子任务移除监听
		 * @private
		 *
		 */
		protected function removeTaskListeners(cmd:Task):void
		{
			cmd.removeEventListener(TaskEvent.TASK_COMPLETE, onTaskComplete);
			cmd.removeEventListener(TaskEvent.TASK_ERROR, onTaskError);
			cmd.removeEventListener(TaskEvent.TASK_PROGRESS, onTaskProgress);
		}
	}
}
