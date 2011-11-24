package com.xingcloud.services
{
	import com.xingcloud.core.XingCloud;
	import com.xingcloud.event.ServiceEvent;
	import com.xingcloud.net.connector.Connector;
	import com.xingcloud.net.connector.MessageResult;
	import com.xingcloud.tasks.Task;
	import com.xingcloud.tasks.TaskEvent;

	/**
	 * 服务基类
	 *
	 */
	public class Service implements IService
	{
		/**
		 *新建服务类
		 * @param onSuccess 调用成功的回调
		 * @param onFail 调用失败的回调
		 *
		 */
		public function Service(onSuccess:Function=null, onFail:Function=null)
		{
			super();
			_onSuccess=onSuccess;
			_onFail=onFail;
		}

		protected var _executor:Connector;
		/**
		 *服务接口名称
		 */
		protected var _commandName:String;
		protected var _commandArgs:Object;
		protected var _result:MessageResult;
		protected var _onSuccess:Function;
		protected var _onFail:Function;

		public function get executor():Task
		{
			if (!_executor)
			{
				_executor=new XingCloud.defaultConnector(_commandName, _commandArgs, XingCloud.needAuth);
				_executor.addEventListener(TaskEvent.TASK_COMPLETE, onComplete);
				_executor.addEventListener(TaskEvent.TASK_ERROR, onError);
			}
			return _executor;
		}

		public function get result():MessageResult
		{
			return _result;
		}

		/**
		 * 在子类中覆盖错误处理函数在服务失败的时候进行处理
		 *
		 */
		protected function onError(event:TaskEvent):void
		{
			_result=event.target.data;
			if (_onSuccess != null)
				_onSuccess(this);
			ServiceManager.instance.dispatchEvent(new ServiceEvent(ServiceEvent.SERVICE_ERROR, this));
		}

		/**
		 * 在子类中覆盖成功处理函数在服务加载成功时进行处理
		 *
		 */
		protected function onComplete(event:TaskEvent):void
		{
			_result=event.target.data;
			if (_onFail != null)
				_onFail(this);
			ServiceManager.instance.dispatchEvent(new ServiceEvent(ServiceEvent.SERVICE_COMPLETE, this));
		}
	}
}
