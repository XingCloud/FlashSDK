package com.xingcloud.services
{
	import com.xingcloud.core.Config;
	import com.xingcloud.net.connector.Connector;
	import com.xingcloud.net.connector.MessageResult;
	import com.xingcloud.net.connector.RESTConnector;
	import com.xingcloud.tasks.SimpleTask;
	import com.xingcloud.tasks.TaskEvent;
	import com.xingcloud.util.Debug;
	import flash.net.URLRequestMethod;

	/**
	 *用于管理资源文件状态
	 * @private
	 */
	public class StatusManager
	{
		private static var _serviceStatus:MessageResult;
		private static var _isReady:Boolean; //文件状态是否已经请求
		private static var _hasStatus:Boolean;

		private static var _instance:StatusManager;

		public static function get instance():StatusManager
		{
			if (!_instance)
			{
				_instance=new StatusManager(new inlock);
			}
			return _instance;
		}

		/**
		 *获取网络加载项的状态信息
		 * @param entry 加载项条目
		 * @return  返回状态信息
		 *
		 */
		public static function getStatus(serviceName:String):String
		{
			var uri:String=getUri(serviceName);
			var apiName:String=getApiName(serviceName);
			if (_serviceStatus && (_serviceStatus.data[uri]) && (_serviceStatus.data[uri][apiName]))
				return _serviceStatus.data[uri][apiName].timestamp;
			else
				return "";
		}

		/**
		 * 状态信息是否请求完毕
		 *
		 */
		public static function get statusReady():Boolean
		{
			return _isReady;
		}

		private static function getUri(name:String):String
		{
			return name.substring(0, name.lastIndexOf("."));
		}


		private static function getApiName(name:String):String
		{
			return name.substring(name.lastIndexOf(".") + 1);
		}

		public function StatusManager(lock:inlock)
		{
			executor=new SimpleTask();
			executor.addExecute(doTask, null, this);
		}

		public var executor:SimpleTask;

		private function doTask():void
		{
			var connector:RESTConnector=new RESTConnector("status",
				{lang: Config.languageType},
				false,
				0,
				Config.gateWay,
				URLRequestMethod.POST);
			connector.addEventListener(TaskEvent.TASK_COMPLETE, onComplete);
			connector.addEventListener(TaskEvent.TASK_ERROR, onError);
			connector.execute();
		}

		private function onComplete(event:TaskEvent):void
		{
			_isReady=true;
			_serviceStatus=(event.task as Connector).data;
			_hasStatus=true;
			Config.systemTime=Number(_serviceStatus.data.server_time) * 1000;
			executor.taskComplete();
		}

		private function onError(event:TaskEvent):void
		{
			_isReady=true;
			_hasStatus=false;
			Debug.warn("Get status failure", this);
			executor.taskError();
		}
	}
}

internal class inlock
{
}
