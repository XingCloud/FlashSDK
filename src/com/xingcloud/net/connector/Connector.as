package com.xingcloud.net.connector
{
	import com.adobe.crypto.HMAC;
	import com.adobe.crypto.MD5;
	import com.adobe.crypto.SHA1;
	import com.xingcloud.core.Config;
	import com.xingcloud.model.ModelBase;
	import com.xingcloud.tasks.Task;
	import com.xingcloud.util.Debug;
	import com.xingcloud.util.Util;
	import com.xingcloud.util.objectencoder.ObjectEncoder;
	import mx.utils.URLUtil;

	/**
	 * 连接器的基类，通过继承此类来实现不同的连接方式
	 *
	 */
	public class Connector extends Task
	{

		/**
		 *创建一个连接器
		 * @param gateway　通信地址
		 * @param command_name　通信接口
		 * @param params　通信参数
		 * @param needAuth　是否安全验证
		 *
		 */
		public function Connector(gateway:String,
			command_name:String,
			params:Object=null,
			needAuth:Boolean=false,
			retryCount:int=0)
		{
			super(0, 999999, retryCount);
			_commandName=command_name;
			_needAuth=needAuth;
			generateParam(params);
			_gateway=gateway;
			parseURL();
			generateURL();
			if (needAuth)
			{
				_header=generateHeader(_commandArgs);
			}
		}

		protected var _commandArgs:Object;
		protected var _commandName:String;
		protected var _gateway:String;
		protected var _header:String;
		protected var _needAuth:Boolean;
		protected var _url:String;
		protected var _msgId:Number;
		protected var _data:MessageResult;

		/**
		 * 获取消息id
		 *
		 */
		public function get msgId():Number
		{
			return _msgId;
		}

		public function get data():MessageResult
		{
			return _data;
		}

		/**
		 *生成通信所请求的真正地址，不同的连接器中需要覆盖实现不同的逻辑
		 *默认为gateway地址
		 */
		protected function generateURL():void
		{
			_url=_gateway;
		}

		/**
		 *生成请求参数
		 * @param value 传入参数
		 *
		 */
		protected function generateParam(value:Object):void
		{
			_msgId=Util.messageId;
			_commandArgs={id: _msgId.toString(), info: Config.appInfo, data: value};
		}

		/**
		 * 生成加密认证所需的认证头
		 * @param params 此次请求中的参数
		 * @return 请求头
		 *
		 */
		private function generateHeader(params:Object):String
		{
			var timeStamp:int=int(Config.systemTime / 1000);
			var oauth:Object={oauth_version: Config.getConfig("authVersion"),
					 oauth_signature_method: Config.getConfig("authMethod"),
					 oauth_consumer_key: Config.getConfig("consumerKey"), realm: _gateway, oauth_timestamp: timeStamp,
					 oauth_nonce: MD5.hash(timeStamp.toString() + Math.random())};
			if (!oauth.oauth_signature_method || !oauth.oauth_consumer_key)
			{
				throw new Error("Not enough parameters for authentication.");
			}
			var temp:Array=[];
			var key:String="";
			for (key in oauth)
			{
				temp.push({key: key, value: oauth[key]});
			}
			temp.sortOn("key");
			var authString:String="";
			for each (var param:Object in temp)
			{
				authString+=param["key"] + "=" + param["value"] + "&";
			}
			authString=authString.substr(0, authString.length - 1);
			var paramString:String="";
			if (params)
			{
				paramString=new ObjectEncoder(params, ObjectEncoder.JSON, true, [ModelBase]).JsonString;
			}
			var base:String='POST&' + encodeURIComponent(_url) + '&' + encodeURIComponent(authString);
			if (paramString)
				base+=('&' + encodeURIComponent(paramString));
			Debug.info("Authorization Base String:" + base, this);
			var signature:String=HMAC.hashToBase64(Config.getConfig("secret_key"), base, SHA1);
			oauth.oauth_signature=signature;
			var headerString:String="";
			for (key in oauth)
			{
				headerString+=key + '="' + oauth[key] + '",';
			}
			headerString=headerString.substr(0, headerString.length - 1);
			return headerString;
		}

		private function parseURL():void //解析gateway，防止地址中带参数
		{
			var parts:Array=_gateway.split("?");
			if (parts.length == 2)
			{
				_gateway=parts[0];
				var urlParams:Object=URLUtil.stringToObject(parts[1], "&");
				for (var key:String in urlParams)
				{
					_commandArgs[key]=urlParams[key];
				}
			}
		}
	}
}
