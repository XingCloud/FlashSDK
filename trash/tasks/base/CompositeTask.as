package com.elex.tasks.base
{

	/**
	 * A CompositeCommand is a composite command for serialCommand or parallelCommand.
	 * 
	 * @author longyangxi
	 */
	
	[Event(type="longsir.event.CommandEvent",name="total_progress")]
	public class CompositeTask extends Task implements ITaskListener
	{
		////////////////////////////////////////////////////////////////////////////////////////
		// Properties                                                                         //
		////////////////////////////////////////////////////////////////////////////////////////
		/** @private */
		protected var _tasks:Vector.<Task>;
		/** @private */
		protected var _messages:Vector.<String>;
		
		
		////////////////////////////////////////////////////////////////////////////////////////
		// Public Methods                                                                     //
		////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * Creates a new CompositeCommand instance.
		 */
		public function CompositeTask(delay:uint=0,timeOut:uint=999999,retryCount:uint=0)
		{
			super(delay,timeOut,retryCount);
			_tasks = new Vector.<Task>();
			_messages = new Vector.<String>();
			this._total=0;
		}
		
		
		/**
		 * Executes the composite command. Abstract method. Be sure to call super.execute()
		 * first in subclassed execute methods.
		 */ 
		override protected function doExecute():void
		{
            super.doExecute();
			enqueueTasks();
		}
		
		////////////////////////////////////////////////////////////////////////////////////////
		// Getters & Setters                                                                  //
		////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * The name identifier of the Task.
		 */
		override public function get name():String
		{
			return "compositeTask";
		}
		
		////////////////////////////////////////////////////////////////////////////////////////
		// Event Handlers                                                                     //
		////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * @private
		 */
		public function onTaskProgress(e:TaskEvent):void
		{
			this.notifyProgress(e.task);
//			if(this._progressPanelParent) e.task.showProgressPanel(this._progressPanelParent,this._modal);
		}
		
		
		/**
		 * @private
		 */
		public function onTaskComplete(e:TaskEvent):void
		{
			removeTaskListeners(e.task);
			notifyTotalProgress();
			next(e.task);
		}
		
		
		/**
		 * @private
		 */
		public function onTaskAbort(e:TaskEvent):void
		{
			removeTaskListeners(e.task);
			notifyTotalProgress();
			next(e.task);
		}
		/**
		 * @private
		 */
		public function onTaskError(e:TaskEvent):void
		{
			removeTaskListeners(e.task);
			notifyTotalProgress();
			notifyError(e.message);
			next(e.task);
		}
		
		protected function  notifyTotalProgress():void
		{
			this._completed++;
			if(this._progressPanelParent) {
//				ProgressManager.setProgress(this._progressPanelParent,this._progressMsg,this._completed,this._total);
			}
			dispatchEvent(new TaskEvent(TaskEvent.TOTAL_PROGRESS, this,
				this._progressMsg));
		}
		
		/**
		 * Executes the next enqueued Task.
		 * @private
		 */
		protected function next(oldTask:Task=null):Boolean
		{
			if(_isAborted||_tasks.length==0){
				if(!_hasError) complete();
				return false;
			}
			return true;
		}
		////////////////////////////////////////////////////////////////////////////////////////
		// Private Methods                                                                    //
		////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * Abstract method. This is the place where you enqueue single Tasks.
		 * @private
		 */
		protected function enqueueTasks():void
		{
		}
		
		
		/**
		 * Enqueues a Taskfor use in the composite Task's execution sequence.
		 * @private
		 */
		public function enqueue(cmd:Task, progressMsg:String =null):void
		{
			if(cmd==null) return;
			_tasks.push(cmd);
			_messages.push(progressMsg);
			_total++;
		}
		
		/**
		 * removeTaskListeners
		 * @private
		 */
		protected function removeTaskListeners(cmd:Task):void
		{
			cmd.removeEventListener(TaskEvent.TASK_COMPLETE, onTaskComplete);
			cmd.removeEventListener(TaskEvent.TASK_ABORT, onTaskAbort);
			cmd.removeEventListener(TaskEvent.TASK_ERROR, onTaskError);
			cmd.removeEventListener(TaskEvent.TASK_PROGRESS,onTaskProgress);
		}
		protected function addTaskListeners(cmd:Task):void
		{
			cmd.addEventListener(TaskEvent.TASK_COMPLETE, onTaskComplete);
			cmd.addEventListener(TaskEvent.TASK_ABORT, onTaskAbort);
			cmd.addEventListener(TaskEvent.TASK_ERROR, onTaskError);
			cmd.addEventListener(TaskEvent.TASK_PROGRESS,onTaskProgress);			
		}
		/**
		 * @private
		 */
		override protected function complete():void
		{
			_tasks = new Vector.<Task>();
			_messages = new Vector.<String>();
			super.complete();
		}
	}
}
