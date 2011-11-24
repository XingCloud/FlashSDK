package com.elex.tasks.net
{
	import flash.events.AsyncErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.NetConnection;
	import flash.net.ObjectEncoding;
	import flash.net.Responder;
	import flash.utils.Dictionary;

	/**
	 * AMF连接任务，通常游戏数据的后台交互用这个，可以指定默认的gateway，也可以使用多个gateway，他将保持一个gateway只会连接一个
	 * example1:
	 * 		AMFConnectTask.defaultGateway="http://www.elex.com/gateway.php";
	 * 		var amf:AMFConnectTask=new AMFConnectTask("buyItem",{itemId:'1001',num:2});
	 * 		amf.onSuccess=this.onSuccess;
	 * 		amf.onFail=this.onFail;
	 * 		amf.excute();
	 * 
	 *      function onSuccess(data:Object):void
	 * 		{
	 * 			//处理返回的数据
	 * 		}
	 *      
	 * example2:
	 * 		var amf:AMFConnectTask=new AMFConnectTask("buyItem",{itemId:'1001',num:2},"http://www.elex.com/gateway.php");
	 *      amf.addEventListener(TaskEvent.TASK_COMPLETE,onSuccess);
	 * 		amf.addEventListener(TaskEvent.TASK_ERROR,onFail);
	 * 		amf.excute();
	 *      function onSuccess(e:TaskEvent):void
	 * 		{
	 * 			var task:AMFConnectTask=e.task as AMFConnectTask;
	 *          var data:Object=task.data;
	 * 			//处理返回的数据
	 * 		}
	 * */
	public class AMFConnecter extends AbstractLoader
	{
		protected var _netConnection:NetConnection;
		protected var _gatewayUrl:String;
		protected var _commandName:String;
		
		public static var defaultGateway:String;
		public var objectEncoding:uint=ObjectEncoding.AMF3;
		public var commandArgs:Object;
		/**
		 * 外部回调
		 * onSuccess(data:Object);
		 * onFail(error:String);
		 * */
		public var onSuccess:Function;
		public var onFail:Function;
		
		// Active connections
		static protected var activeConnections:Dictionary=new Dictionary();
		/**
		 * 如果gateWay为null，请确保设置了defaultGateway属性
		 * */
		public function AMFConnecter(command_name:String, command_args:Object=null,gateWay:String=null)
		{
			this._timeout=60;
			//this._retryCount=3;
			this._gatewayUrl=gateWay;
			this._commandName = command_name;
			this.commandArgs = command_args;
			super(null);
			//如果没有传递gateway，那么使用默认的gateway
			if(this._gatewayUrl==null) this._gatewayUrl=defaultGateway;
			if(this._gatewayUrl==null){
				throw new Error("Please give me a gateway or set a defaultGateway!");
			}
		}
		/**
		 * 保证一个gateWay地址只有一个连接
		 */
		static protected function getActiveConnection( url:String):NetConnection {
			if(activeConnections[url]==null) {
				var nc:NetConnection = new NetConnection();	
				//nc.connect(url);
				activeConnections[url] = nc;
			}
			return activeConnections[url];
		}
		static protected function closeActiveConnection(url:String):void
		{
			var nc:NetConnection = activeConnections[url];
			if(nc!=null && nc.connected) {
				nc.close();
				delete activeConnections[url];
			}
		}
		override protected function doLoad():void
		{
			if(_netConnection==null) {
				_netConnection = AMFConnecter.getActiveConnection( _gatewayUrl);
				if(!_netConnection.connected){
					this.addListeners();
					_netConnection.connect(_gatewayUrl);
				}
				_netConnection.objectEncoding = objectEncoding;
			} 
			var _amfResponder:Responder = new Responder(onCallSuccess, onCallError);
			var args:Array = [commandName, _amfResponder];
			args.push( commandArgs );
			_netConnection.call.apply( _netConnection, args ); 	
			trace("AMFConnectTask->doLoad: ","Start connect amf: "+_gatewayUrl);
		}
		override protected function doCancel():void
		{
			AMFConnecter.closeActiveConnection( _gatewayUrl);
		}
		override protected function addListeners():void
		{
			if(_netConnection==null) return;
			_netConnection.addEventListener( NetStatusEvent.NET_STATUS, onNetStatusEvent );
			_netConnection.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onLoadError );
			_netConnection.addEventListener( IOErrorEvent.IO_ERROR,onLoadError );
			_netConnection.addEventListener( AsyncErrorEvent.ASYNC_ERROR, onLoadError );			
		}
		override protected function removeListeners():void
		{
			if(_netConnection==null) return;
			_netConnection.removeEventListener( NetStatusEvent.NET_STATUS, onNetStatusEvent );
			_netConnection.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, onLoadError );
			_netConnection.removeEventListener( IOErrorEvent.IO_ERROR, onLoadError );
			_netConnection.removeEventListener( AsyncErrorEvent.ASYNC_ERROR, onLoadError );
		}
		private function onCallSuccess(data:Object):void
		{
			//Logger.info(this,"onCallSuccess","The AMF connection successed with gateway: "+this._gatewayUrl);
			this.data=data;
			this.complete();
			if(this.onSuccess!=null){
				onSuccess(data);
			}
		}
		private function onCallError(error:Object):void
		{
			//description
			//details
			var errMsg:String=(error==null)?"Undefined amf error!":String(error.faultString+" in "+error.faultDetail);
			this.notifyError(errMsg);
		}
		override protected function notifyError(errorMsg:String):void
		{
			super.notifyError(errorMsg);
			if(!this._hasError) return;
			if(this.onFail!=null){
				onFail(errorMsg);
			}			
		}
		//todo,怎么连发了好几个
		private function onNetStatusEvent(event:NetStatusEvent):void
		{
			if(event.info.level=='error') {
				if(this._hasError) return;
				var errorInfo:String="AMF error code: "+event.info.code;
				trace("AMFConnectTask->onNetStatusEvent: ",errorInfo);
				removeListeners();
				this.notifyError(errorInfo);
			} else {
				//Logger.info(this,"onNetStatusEvent","NetStatus Event: " + event.info.code );
			}
		}
		public function get gatewayUrl():String {
			return _gatewayUrl;
		}		
		public function get netConnection():NetConnection {
			return _netConnection;
		}		
		public function get commandName():String {
			return _commandName;
		}
	}
}