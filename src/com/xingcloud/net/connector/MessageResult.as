package com.xingcloud.net.connector
{
	import com.adobe.serialization.json.JSON;

	/**
	 *行云后台返回数据类，包括状态码，交互数据及出错消息(如果出现错误)
	 */
	public class MessageResult
	{
		/**
		 *请求成功
		 */
		public static const SUCCESS_CODE:uint=200;
		/**
		 *请求参数不合法
		 */
		public static const CLIENT_ERROR_CODE:uint=400;
		/**
		 *服务端出错
		 */
		public static const SERVER_ERROR_CODE:uint=500;
		/**
		 * 返回结果解析出错
		 */
		public static const RESULT_DECODE_ERROR_CODE:uint=1000;
		/**
		 * 网络错误
		 *
		 */
		public static const NETWORK_ERROR_CODE:uint=1001;

		/**
		 *从服务器返回结果解析出Result对象
		 * @param data 服务器返回对象
		 * @return  结果对象
		 *
		 */
		public static function createResult(data:Object):MessageResult
		{
			var result:MessageResult;
			result=new MessageResult(data.id, data.code, data.message, data.data);
			return result;
		}

		/**
		 *实例化一个远程调用结果
		 * @param id 消息id
		 * @param code 结果状态码
		 * @param message 调用结果消息
		 * @param data 调用结果数据
		 *
		 */
		public function MessageResult(id:Number, code:uint=SUCCESS_CODE, message:String="", data:Object=null)
		{
			this.code=code;
			this.errorMsg=message;
			this.data=data;
			this.id=id;
		}

		/**
		*交互状态码
		*/
		public var code:uint;
		/**
		*交互数据
		*/
		public var data:Object;
		/**
		*出错消息
		*/
		public var errorMsg:String;
		/**
		 *消息id
		 */
		public var id:Number;

		/**
		 * 是否调用成功
		 *
		 */
		public function get success():Boolean
		{
			return code == MessageResult.SUCCESS_CODE;
		}
	}
}
