package com.xingcloud.services
{
	import com.adobe.crypto.MD5;
	import com.xingcloud.core.Config;
	import com.xingcloud.core.XingCloud;
	import com.xingcloud.event.ServiceEvent;
	import com.xingcloud.event.XingCloudEvent;
	import com.xingcloud.net.connector.Connector;
	import com.xingcloud.tasks.Task;
	import com.xingcloud.tasks.TaskEvent;
	import com.xingcloud.core.xingcloud_internal;
	use namespace xingcloud_internal;
	/**
	 * 注册服务
	 *
	 */
	public class RegisterService extends Service
	{
		public function RegisterService(account:Object, onSuccess:Function=null, onFail:Function=null)
		{
			super(onSuccess, onFail);
			if (!account.username || !account.password)
				throw new Error("missing password or username.");
			account.password=MD5.hash(account.password);
			_commandName=Config.REGISTER_SERVICE;
			_commandArgs={account: account}
		}

		override protected function onComplete(event:TaskEvent):void
		{
			_result=event.target.data;
			if (_onSuccess != null)
				_onSuccess(this);
			ServiceManager.instance.dispatchEvent(new ServiceEvent(ServiceEvent.REGISTER_SUCCESS, this));
		}

		override protected function onError(event:TaskEvent):void
		{
			_result=event.target.data;
			if (_onFail != null)
				_onFail(this);
			ServiceManager.instance.dispatchEvent(new ServiceEvent(ServiceEvent.REGISTER_ERROR, this));
		}
	}



}
