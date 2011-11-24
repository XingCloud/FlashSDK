package com.xingcloud.tasks
{

	/**
	 * 用于构成复合对象内的元素，使该对象具有Task的控制流程而不必继承Task
	 *
	 */
	public class SimpleTask extends Task
	{
		public function SimpleTask(delay:uint=0, timeOut:uint=999999, retryCount:uint=0)
		{
			super(delay, timeOut, retryCount);
			_funQueue=[];
			_argQueue=[];
		}

		private var _funQueue:Array;
		private var _argQueue:Array;
		private var _target:Object

		/**
		 *任务完成
		 *
		 */
		public function taskComplete():void
		{
			this.notifyComplete(this);
		}

		/**
		 *任务失败
		 *
		 */
		public function taskError():void
		{
			this.notifyError(this);
		}

		/**
		 *添加任务执行函数
		 * @param func 添加的函数
		 * @param arguments 传递的参数
		 * @target 执行主体
		 */
		public function addExecute(func:Function, arguments:Array=null, target:Object=null):void
		{
			_funQueue.push(func);
			_argQueue.push(arguments);
			_target=target;
		}

		/**
		 * 知会进度
		 * @param complete 已完成
		 * @param total 总数
		 *
		 */
		public function setProgress(complete:Number, total:Number):void
		{
			this._completeNum=complete;
			this._totalNum=totalNum;
			this.notifyProgress(this);
		}

		override protected function doExecute():void
		{
			super.doExecute();
			while (_funQueue.length != 0)
			{
				var cmd:Function=_funQueue.pop();
				cmd.apply(_target, _argQueue.pop());
			}
		}
	}
}
