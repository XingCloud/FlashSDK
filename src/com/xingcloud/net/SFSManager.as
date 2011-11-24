package com.xingcloud.net
{
	import com.smartfoxserver.v2.SmartFox;
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.data.SFSArray;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	import com.smartfoxserver.v2.requests.ExtensionRequest;
	import com.smartfoxserver.v2.requests.LoginRequest;
	import com.xingcloud.core.Config;
	import com.xingcloud.net.connector.SFSConnector;
	import com.xingcloud.util.Debug;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;

	/**
	 *与服务器连接成功后进行派发
	 */
	[Event(type="com.smartfoxserver.v2.core.SFSEvent", name="connection")]
	/**
	 *登陆成功后派发
	 */
	[Event(type="com.smartfoxserver.v2.core.SFSEvent", name="login")]
	/**
	 *与服务器连接丢失时派发
	 */
	[Event(type="com.smartfoxserver.v2.core.SFSEvent", name="connection_lost")]
	/**
	 *与服务器连接恢复时派发
	 */
	[Event(type="com.smartfoxserver.v2.core.SFSEvent", name="connection_resume")]
	/**
	 *重试连接时派发
	 */
	[Event(type="com.smartfoxserver.v2.core.SFSEvent", name="connection_retry")]
	/**
	 *登陆出错时派发
	 */
	[Event(type="com.smartfoxserver.v2.core.SFSEvent", name="login_error")]
	/**
	 *登出时派发
	 */
	[Event(type="com.smartfoxserver.v2.core.SFSEvent", name="logout")]
	/**
	 *自定义扩展接口数据返回时派发
	 */
	[Event(type="com.smartfoxserver.v2.core.SFSEvent", name="extension_response")]
	/**
	 * SmartFoxServer管理器，用于连接SFS和收发SFS消息。
	 *
	 */
	public class SFSManager extends EventDispatcher
	{
		private static var _instance:SFSManager;

		public static function get instance():SFSManager
		{
			if (!_instance)
				_instance=new SFSManager();
			return _instance;
		}

		public function SFSManager()
		{
			zone=Config.getConfig("sfszone");
			var sfs:String=Config.getConfig("sfs");
			host=sfs.split(":")[0];
			port=sfs.split(":")[1];
			_sfsServer=new SmartFox();
			_sfsServer.addEventListener(SFSEvent.CONNECTION, onConnection);
			_sfsServer.addEventListener(SFSEvent.LOGIN, onLogin);
			_sfsServer.addEventListener(SFSEvent.CONNECTION_LOST, onConnectLost);
			_sfsServer.addEventListener(SFSEvent.CONNECTION_RESUME, onResume);
			_sfsServer.addEventListener(SFSEvent.CONNECTION_RETRY, onRetry);
			_sfsServer.addEventListener(SFSEvent.LOGIN_ERROR, onLoginError);
			_sfsServer.addEventListener(SFSEvent.LOGOUT, onLoginOut);
			_sfsServer.addEventListener(SFSEvent.EXTENSION_RESPONSE, onResponse);
			unSendMessage=[];
			_registerQueue=new Dictionary(false);
		}

		/**
		 * 服务地址
		 * */
		public var host:String;
		/**
		 * 服务端口
		 * */
		public var port:uint;
		/**
		 * 服务区域
		 * */
		public var zone:String;
		private var _sfsServer:SmartFox;
		private var unSendMessage:Array;
		private var isLogin:Boolean;
		private var isConnecting:Boolean;
		private var isLogining:Boolean;
		private var _registerQueue:Dictionary;

		/**
		 *是否连接
		 *
		 */
		public function get isConnected():Boolean
		{
			return _sfsServer.isConnected;
		}

		/**
		 *连接到服务器
		 *
		 */
		public function connect():void
		{
			isConnecting=true;
			_sfsServer.connect(host, port);
		}

		/**
		 *发送 SFS请求
		 * @param params 发送的参数
		 * @param extCmd 请求的扩展服务的名称
		 *
		 */
		public function send(params:SFSObject, extCmd:String):void
		{
			if (isConnected && isLogin)
				_sfsServer.send(new ExtensionRequest(extCmd, params));
			else
			{
				if (!isConnected && !isConnecting)
					connect();
				unSendMessage.push(new ExtensionRequest(extCmd, params));
			}
		}

		/**
		 *为特定消息注册处理函数
		 * @param msgid 注册的消息id
		 * @param successHandler 调用成功处理函数
		 * @param failHandler 调用失败处理函数
		 *
		 */
		public function registerMessage(msgid:Number, successHandler:Function, failHandler:Function):void
		{
			_registerQueue[msgid]=[successHandler, failHandler];
		}

		/**
		 * 获取SFS类
		 *
		 */
		public function get sfsServer():SmartFox
		{
			return _sfsServer;
		}

		protected function onRetry(event:SFSEvent):void
		{
			dispatchEvent(event);
		}

		protected function onConnection(event:SFSEvent):void
		{
			if (event.params.success)
			{
				_sfsServer.send(new LoginRequest(Config.getConfig("sfs_user") || "",
					Config.getConfig("sfs_pwd") || "",
					zone));
				isLogining=true;
			}
			else
			{
				Debug.error("Connect to SFS Failure: " + event.params.errorMessage, this);
			}
			isConnecting=false;
			dispatchEvent(event);
		}

		protected function onLogin(event:SFSEvent):void
		{
			isLogin=true;
			sendUnhandleMsg();
			isLogining=false;
			dispatchEvent(event);
		}

		protected function onLoginError(event:SFSEvent):void
		{
			isLogin=false;
			isLogining=false;
			dispatchEvent(event);
		}

		protected function onLoginOut(event:SFSEvent):void
		{
			isLogin=false;
			isLogining=false;
			dispatchEvent(event);
		}

		protected function onConnectLost(event:SFSEvent):void
		{
			isLogin=false;
			isConnecting=false;
			Debug.warn("Connection lost. Reason: " + event.params.reason);
			dispatchEvent(event);
		}

		protected function onResume(event:SFSEvent):void
		{
			_sfsServer.send(new LoginRequest(Config.getConfig("sfs_user") || "",
				Config.getConfig("sfs_pwd") || "",
				zone));
			dispatchEvent(event);
		}

		protected function onResponse(event:SFSEvent):void
		{
			var result:Object=event.params.params.toObject();
			var handlers:Array=_registerQueue[result.id];
			if (handlers)
			{
				if (result.code == 200)
				{
					handlers[0](result);
				}
				else
				{
					handlers[1](result);
				}
				delete _registerQueue[result.id];
			}
			else
			{
				Debug.warn("Message " + result.id + " hasn't been registered.", this);
			}
			dispatchEvent(event);
		}

		private function sendUnhandleMsg():void
		{
			while (unSendMessage.length != 0)
			{
				_sfsServer.send(unSendMessage.shift());
			}
		}
	}
}
