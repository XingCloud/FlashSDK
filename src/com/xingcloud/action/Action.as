package com.xingcloud.action
{
	import com.xingcloud.net.IPackableRequest;
	import com.xingcloud.util.Reflection;

	/**
	 * Action基类，用于创建相应的动作逻辑和后台进行通信完成相应操作。
	 *
	 */
	public class Action implements IPackableRequest
	{
		/**
		 * 定义一个一般的action
		 * @param params  传到后台的参数
		 * @param name action的名称，如果不设置此参数，则名称默认为此Action类名，如果后台Action进行的分层，Action不在默认的
		 * 根路径下，则需要设置此参数为Action从其根目录开始完整的子路径，如shop.BuyAction
		 * */
		public function Action(params:Object=null, name:String=null)
		{
			this._params=params;
			_name=name;
		}

		protected var _params:Object;
		protected var _name:String;

		/**
		 *获取参数
		 * @return
		 *
		 */
		public function get params():Object
		{
			return this._params;
		}

		/**
		 *action名称
		 * @return
		 *
		 */
		public function get name():String
		{
			if (!_name)
				_name=Reflection.tinyClassName(this);
			return _name;
		}

		/**
		 *立即发送action
		 *
		 */
		public function send():void
		{
			ActionManager.instance.addAction(this);
			ActionManager.instance.send();
		}

		/**
		 *进入请求队列，等待系统按照设置的队列长度和间隔时间自动批量发送
		 *
		 */
		public function queue():void
		{
			ActionManager.instance.addAction(this);
		}

		public function handleDataBack(result:Object):void
		{
			if (result.code == 200)
			{
				onSuccess(result);
			}
			else
			{
				onFail(result);
			}
		}

		public function get data():Object
		{
			return {name: name, params: params};
		}

		/**
		 * 处理成功后回调函数，需覆盖编写具体逻辑
		 * @param result
		 *
		 */
		protected function onSuccess(result:Object):void
		{

		}

		/**
		 * 处理失败后回调函数，需覆盖编写具体逻辑
		 * @param result
		 *
		 */
		protected function onFail(result:Object):void
		{

		}
	}
}
