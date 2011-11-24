package com.xingcloud.net.connector
{
	import com.smartfoxserver.v2.entities.data.SFSObject;
	import com.xingcloud.core.Config;
	import com.xingcloud.model.ModelBase;
	import com.xingcloud.net.SFSManager;
	import com.xingcloud.util.Debug;
	import com.xingcloud.util.objectencoder.ObjectEncoder;

	/**
	 * SFS连接器，用于进行SFS通信
	 *
	 */
	public class SFSConnector extends Connector
	{
		/**
		 *创建SFS连接器，发送一次sfs请求
		 * @param extension_name sfs扩展名
		 * @param command_name 调用接口名称
		 * @param command_args 调用参数
		 * @param needAuth 是否需要安全验证
		 *
		 */
		public function SFSConnector(command_name:String,
			command_args:Object=null,
			needAuth:Boolean=false,
			retryCount:int=0,
			extension_name:String="service")
		{
			super("", command_name, command_args, needAuth, retryCount);
			_extension_name=extension_name;
		}

		private var _extension_name:String;

		/**
		 *获取扩展服务的名称
		 *
		 */
		public function get extension_name():String
		{
			return _extension_name;
		}

		override protected function doExecute():void
		{
			super.doExecute();
			SFSManager.instance.registerMessage(msgId, onCompleteHandler, onErrorHandler);

			SFSManager.instance.send(getParam(), _extension_name);
			Debug.info("Send SFS request to {0},params is {1}", this, _commandName, _commandArgs);
		}

		protected function onCompleteHandler(result:Object):void
		{
			Debug.info("Get SFS response from {0},result is {1}", this, _commandName, result);
			_data=MessageResult.createResult(result);
			notifyComplete(this);
		}


		/**
		 *   @private
		 */
		protected function onErrorHandler(fault:Object):void
		{
			Debug.error("Get SFS error from {0},error is {1}", this, _commandName, fault);
			_data=MessageResult.createResult(fault);
			notifyError(this);
		}

		private function getParam():SFSObject
		{
			_commandArgs={api: _commandName, data: _commandArgs};
			return new ObjectEncoder(_commandArgs, ObjectEncoder.SFS, false, [ModelBase]).SfsObject;
		}
	}
}
