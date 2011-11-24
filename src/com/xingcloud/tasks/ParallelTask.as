package com.xingcloud.tasks
{

	/**
	 * 并行执行任务
	 *  <p>此复合任务中的子任务按照可以并行执行，可以指定同时执行的任务数，如果没有进行指定，则
	 * 一次性执行全部任务。</p>
	 */
	public class ParallelTask extends CompositeTask
	{
		/**
		 *实例化并行执行任务
		 * @param bandNum 最大并行任务数
		  * @param delay 延迟执行时间
		 * @param timeOut 超时时间
		 * @param retryCount 重试次数
		 *
		 */
		public function ParallelTask(bandNum:int=0, delay:uint=0, timeOut:uint=999999, retryCount:uint=0)
		{
			super(delay, timeOut, retryCount);
			_bandNum=bandNum;
			_currentTasks=[];
		}

		////////////////////////////////////////////////////////////////////////////////////////
		// Properties            									                         //
		////////////////////////////////////////////////////////////////////////////////////////
		/**
		 * @private
		 */
		protected var _bandNum:int;
		/**@private*/
		protected var _currentTasks:Array;

		/**
		 *并行执行的任务数
		 *
		 */
		public function get bandNum():int
		{
			return _bandNum;
		}

		/**
		 * @private
		 */
		public function set bandNum(value:int):void
		{
			_bandNum=value;
		}

		////////////////////////////////////////////////////////////////////////////////////////
		// Override Method                                                                  //
		////////////////////////////////////////////////////////////////////////////////////////

		/**
		 * @inheritDoc
		 */
		override protected function next():Boolean
		{
			var temp:Task;
			if (_bandNum == 0)
			{
				while (super.next())
				{
					temp=_exeQueue.shift();
					addTaskListeners(temp);
					_currentTasks.push(temp);
					temp.execute();
				}
			}
			else
			{
				var runCount:int=_currentTasks.length;
				if (super.next())
				{
					while (runCount < _bandNum)
					{
						temp=_exeQueue.shift();
						addTaskListeners(temp);
						_currentTasks.push(temp);
						temp.execute();
						runCount++;
					}
				}
			}
			if ((_currentTasks.length + _exeQueue.length) != 0)
				return true;
			else
				return false;
		}

		/**
		 * @inheritDoc
		 */
		override protected function onTaskComplete(e:TaskEvent):void
		{
			var index:int=_currentTasks.indexOf(e.task);
			if (index != -1)
			{
				_currentTasks.splice(index, 1);
			}
			super.onTaskComplete(e);
		}

		/**
		 * @inheritDoc
		 */
		override protected function onTaskError(e:TaskEvent):void
		{
			var index:int=_currentTasks.indexOf(e.task);
			if (index != -1)
			{
				_currentTasks.splice(index, 1);
			}
			super.onTaskError(e);
		}
	}
}
