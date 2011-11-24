package com.xingcloud.net
{

	/**
	 * 可打包的请求
	 *
	 */
	public interface IPackableRequest
	{
		/**
		 * 处理返回的数据
		 * @param result 该请求的返回结果
		 *
		 */
		function handleDataBack(result:Object):void;
		/**
		 * 获取请求参数
		 *
		 */
		function get data():Object;
	}
}
