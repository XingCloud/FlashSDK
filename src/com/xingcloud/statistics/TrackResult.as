package com.xingcloud.statistics
{
	import elex.socialize.mode.RequestResponder;

	public class TrackResult
	{
		public function TrackResult()
		{
		}

		private var _responder:RequestResponder;

		/**
		 *结果消息
		 *
		 */
		public function get message():String
		{
			if (_responder)
				return _responder.message;
			else
				return "";
		}

		/**
		 *结果数据
		 *
		 */
		public function get data():*
		{
			if (_responder)
				return _responder.data;
			else
				return null;
		}

		/**
		 *结果方法
		 *
		 */
		public function get method():String
		{
			if (_responder)
				return _responder.method;
			else
				return "";
		}

		/**
		 * 结果代码
		 *
		 */
		public function get code():String
		{
			if (_responder)
				return _responder.code;
			else
				return "";
		}

		internal function set responder(r:RequestResponder):void //设置GDP对应的响应对象
		{
			_responder=r;
		}
	}
}
