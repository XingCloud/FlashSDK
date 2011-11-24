package com.elex.tasks.base 
{
	import flash.events.Event;
	/**
	 * An event that is used to be broadcast from commands to indicate the state of the
	 * command.
	 * 
	 * @see com.hexagonstar.pattern.cmd.Command
	 * @see com.hexagonstar.pattern.cmd.CompositeCommand
	 * @see com.hexagonstar.pattern.cmd.PausableCommand
	 * @see com.hexagonstar.pattern.cmd.ICommandListener
	 * 
	 * @author longyangxi
	 * @version 1.0.0
	 */
	public class TaskEvent extends Event
	{
		////////////////////////////////////////////////////////////////////////////////////////
		// Constants                                                                          //
		////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * A constant for command events which signals that the command has completed
		 * execution.
		 */
		public static const TASK_COMPLETE:String	= "task_complete";
			
		/**
		 *简单task的progress
		 */
		public static const TASK_PROGRESS:String	= "task_progress";
		/**
		 * 对于复合task的总progress，比如5个子task执行了3个
		 * */
		public static const TOTAL_PROGRESS:String="total_progress";
		
		/**
		 * A constant for task events which signals that the task has been aborted.
		 */
		public static const TASK_ABORT:String		= "task_abort";
		
		/**
		 * A constant for task events which signals that an error occured during the the
		 * task execution.
		 */
		public static const TASK_ERROR:String		= "task_error";
		
		
		////////////////////////////////////////////////////////////////////////////////////////
		// Properties                                                                         //
		////////////////////////////////////////////////////////////////////////////////////////
		
		/** @private */
		protected var _task:Task;
		/** @private */
		protected var _message:String;
		/** @private */
		
		
		////////////////////////////////////////////////////////////////////////////////////////
		// Public Methods                                                                     //
		////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * Creates a new CommandEvent instance.
		 * 
		 * @param type The type string for the event.
		 * @param task The task this event is fired from.
		 * @param message The progress message of the task.
		 * @param progress The progress value of the task.
		 */
		public function TaskEvent(type:String,
										 task:Task,
										 message:String = null)
		{
			super(type);
			_task = task;
			_message = message;
		}
		
		
		/**
		 * Clones the event.
		 */
		override public function clone():Event
		{
			return new TaskEvent(type, _task, _message);
		}
		
		
		////////////////////////////////////////////////////////////////////////////////////////
		// Getters & Setters                                                                  //
		////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * The task that broadcasted the event.
		 */
		public function get task():Task
		{
			return _task;
		}
		
		
		/**
		 * For an error event the error message and for a progress event the message string
		 * associated with the task progress.
		 */
		public function get message():String
		{
			return _message;
		}

	}
}
