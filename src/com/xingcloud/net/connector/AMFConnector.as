package com.xingcloud.net.connector
{
	import com.xingcloud.core.Config;
	import com.xingcloud.model.ModelBase;
	import com.xingcloud.util.Debug;
	import com.xingcloud.util.objectencoder.ObjectEncoder;
	import flash.events.AsyncErrorEvent;
	import flash.events.ErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.NetConnection;
	import flash.net.Responder;

	/**
	 *AMF连接器，用于创建AMF连接
	 *
	 */
	public class AMFConnector extends Connector
	{

		/**
		 * 创建一个AMF连接器
		 * @param command_name 调用的服务名称
		 * @param command_args 传递的参数
		 * @param header 请求头，用于安全验证
		 * @param gateWay 通信地址
		 *
		 */
		public function AMFConnector(command_name:String,
			command_args:Object=null,
			needAuth:Boolean=false,
			retryCount:int=0,
			gateWay:String="",
			objectEncoding:uint=3)
		{
			if (!gateWay)
				gateWay=Config.amfGateway;
			super(gateWay, command_name, command_args, needAuth, retryCount);
			_objectEncoding=objectEncoding;
		}

		private var _netConnection:NetConnection;

		private var _objectEncoding:uint;

		/**
		 * @inheritDoc
		 */
		override protected function clear():void
		{
			super.clear();
			removeListeners();
			_netConnection.close();
		}

		/**
		 * @inheritDoc
		 */
		override protected function doExecute():void
		{
			_netConnection=new NetConnection();
			if (!_netConnection.connected)
			{
				addListeners();
				_netConnection.connect(_url);
			}
			_netConnection.objectEncoding=_objectEncoding;
			var _amfResponder:Responder=new Responder(onCallSuccess, onCallError);
			var args:Array=[_commandName, _amfResponder];
			args.push(new ObjectEncoder(_commandArgs, ObjectEncoder.AMF, false, [ModelBase]).AmfObject);
			if (_needAuth)
				_netConnection.addHeader("Authorization", false, _header);
			_netConnection.call.apply(_netConnection, args);
			super.doExecute();
			Debug.info("Send AMF request to {0}, params is {1}", this, _commandName, _commandArgs);
		}

		private function addListeners():void
		{
			if (_netConnection == null)
				return;
			_netConnection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatusEvent);
			_netConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError);
			_netConnection.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			_netConnection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onLoadError);
		}

		private function onCallError(error:Object):void
		{
			Debug.error("Get AMF error from {0},error is {1}", this, _commandName, error);
			var errMsg:String=(error == null) ? "AMF Unknow Error." : error.faultString;
			_data=new MessageResult(msgId, MessageResult.NETWORK_ERROR_CODE, errMsg, error);
			this.notifyError(this);
		}


		private function onCallSuccess(result:Object):void
		{
			Debug.info("Get AMF response from {0},result is {1}", this, _commandName, result);
			_data=MessageResult.createResult(result);
			if ((_data as MessageResult).success)
				notifyComplete(this);
			else
				notifyError(this);
		}

		private function onLoadError(event:ErrorEvent):void
		{
			var errMsg:String=event.text;
			_data=new MessageResult(msgId, MessageResult.NETWORK_ERROR_CODE, errMsg, event);
			this.notifyError(this);
		}

		private function onNetStatusEvent(event:NetStatusEvent):void
		{
			if (event.info.level == 'error')
			{
				var errorInfo:String=event.info.code;
				_data=new MessageResult(msgId, MessageResult.NETWORK_ERROR_CODE, errorInfo, event);
				this.notifyError(this);
			}
		}

		private function removeListeners():void
		{
			if (_netConnection == null)
				return;
			_netConnection.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatusEvent);
			_netConnection.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError);
			_netConnection.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			_netConnection.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, onLoadError);
		}
	}
}
