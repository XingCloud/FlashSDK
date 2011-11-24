package com.elex.tasks.base
{
	import com.elex.tasks.base.Task;


	public class ParallelTask extends CompositeTask
	{
		public function ParallelTask(delay:uint=0,timeOut:uint=999999,retryCount:uint=0)
		{
			super(delay,timeOut,retryCount);
		}
		override protected function doExecute():void
		{
			super.doExecute();
			if(_total==0) {
				this.complete();
				return;
			}
			//复制一个，以免实时执行命令后_commands被删一个后出错
			var tempTasks:Vector.<Task>=_tasks.concat();
			for(var i:int=0;i<_total;i++){
				var task:Task=tempTasks[i];
				this.addTaskListeners(task);
				task.execute();
			}
			tempTasks=null;
		}
		
		
		/**
		 * Aborts the command's execution.
		 */
		override public function abort():void
		{
			super.abort();
			for each (var t:Task in _tasks){
				t.abort();
			}
		}
		/**
		 * Executes the next enqueued Task.
		 * @private
		 */
		override protected function next(oldTask:Task=null):Boolean
		{
			if(oldTask){
				var i:int=_tasks.indexOf(oldTask);
				if(i>=0) _tasks.splice(i,1);
			}
			return super.next(oldTask);
		}
		/**
		 * The name identifier of the task.
		 */
		override public function get name():String
		{
			return "parallelTask";
		}
	}
}