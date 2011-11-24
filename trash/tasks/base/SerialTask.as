package com.elex.tasks.base{	import com.elex.tasks.base.Task;

	/**	 * A CompositeCommand is a composite command that consists of several single	 * commands which are executed in sequential order.	 * 	 * @author longyangxi	 */		public class SerialTask extends CompositeTask	{		////////////////////////////////////////////////////////////////////////////////////////		// Properties                                                                         //		////////////////////////////////////////////////////////////////////////////////////////		/** @private */		protected var _currentTask:Task;		/** @private */		protected var _currentMsg:String;						////////////////////////////////////////////////////////////////////////////////////////		// Public Methods                                                                     //		////////////////////////////////////////////////////////////////////////////////////////				/**		 * Creates a new CompositeCommand instance.		 */		public function SerialTask(delay:uint=0,timeOut:uint=999999,retryCount:uint=0)		{			super(delay,timeOut,retryCount);		}		public function get currentTask():Task		{			return _currentTask;		}				/**		 * Executes the composite command. Abstract method. Be sure to call super.execute()		 * first in subclassed execute methods.		 */ 		override protected function doExecute():void		{			super.doExecute();			next();		}						/**		 * Aborts the command's execution.		 */		override public function abort():void		{			super.abort();			if (_currentTask) _currentTask.abort();		}						////////////////////////////////////////////////////////////////////////////////////////		// Getters & Setters                                                                  //		////////////////////////////////////////////////////////////////////////////////////////				/**		 * The name identifier of the command.		 */		override public function get name():String		{			return "serialCommand";		}				/**		 * The Message associated to the command's progress.		 */		override public function get progressMsg():String		{			if(_currentMsg) return _currentMsg;			return _currentTask.progressMsg;		}		////////////////////////////////////////////////////////////////////////////////////////		// Private Methods                                                                    //		////////////////////////////////////////////////////////////////////////////////////////		/**		 * Executes the next enqueued command.		 * @private		 */		override protected function next(oldTask:Task=null):Boolean		{		     var hasNext:Boolean=super.next(oldTask);			 if(!hasNext) return false;			_currentMsg = _messages.shift();			_currentTask = _tasks.shift();			this.addTaskListeners(_currentTask);			_currentTask.execute();			return true;		}		/**		 * @private		 */		override protected function complete():void		{			_currentTask = null;			_currentMsg = null;			super.complete();		}	}}