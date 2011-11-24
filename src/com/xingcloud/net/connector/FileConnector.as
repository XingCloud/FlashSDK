package com.xingcloud.net.connector
{
	import com.adobe.serialization.json.JSON;
	import com.adobe.serialization.json.JSONParseError;
	import com.xingcloud.core.XingCloud;
	import com.xingcloud.util.Debug;
	import com.xingcloud.util.Util;
	import com.xingcloud.util.objectencoder.ObjectEncoder;
	import flash.errors.EOFError;
	import flash.errors.IOError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;

	/**
	 * 文件请求连接器，用于创建请求文件的连接器
	 */
	public class FileConnector extends RESTConnector
	{
		/**
		 *创建文件连接器
		 * @param gateway 请求地址
		 * @param command_name 请求接口
		 * @param params 请求参数
		 * @param needAuth 是否需要安全验证
		 * @param format 请求结果格式，详见<code>URLLoaderDataFormat</code>
		 *
		 */
		public function FileConnector(gateway:String,
			command_name:String,
			params:Object=null,
			method:String=URLRequestMethod.POST,
			needAuth:Boolean=false,
			format:String=URLLoaderDataFormat.TEXT)
		{
			super(command_name, params, needAuth, 0, gateway, method, format);
		}

		/**
		 *   @private
		 */
		override protected function onCompleteHandler(evt:Event):void
		{
			try
			{
				var uncompress:Object;
				if (XingCloud.needCompress)
					uncompress=Util.unCompressData(_urlLoader.data, _format == URLLoaderDataFormat.TEXT);
				else
					uncompress=_urlLoader.data;
				var result:Object=JSON.decode(uncompress as String);
				_data=MessageResult.createResult(result);
				Debug.error("Get file error from {0},error is {1}", this, _commandName, uncompress as String);
				notifyError(this);
			}
			catch (e:Error)
			{
				if (e is JSONParseError || e is TypeError)
				{
					Debug.info("Get file content from {0},content is {1}", this, _commandName, uncompress as String);
					_data=new MessageResult(msgId, MessageResult.SUCCESS_CODE, "", uncompress);
					notifyComplete(this);
				}
				else if (e is IOError)
				{
					_data=new MessageResult(msgId,
						MessageResult.RESULT_DECODE_ERROR_CODE,
						"Uncompress result fails:" + e.message,
						_urlLoader.data);
					Debug.error("Get REST error from {0},uncompress result fails:{1}", this, _commandName, e.message);
					notifyError(this);
				}
				else if (e is EOFError)
				{
					_data=new MessageResult(msgId,
						MessageResult.RESULT_DECODE_ERROR_CODE,
						"Read result fails:" + e.message,
						_urlLoader.data);
					Debug.error("Get REST error from {0},read result fails:{1}", this, _commandName, e.message);
					notifyError(this);
				}
			}
		}
	}
}
