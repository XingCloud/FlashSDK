package com.xingcloud.action
{
	import com.xingcloud.core.xingcloud_internal;
	import com.xingcloud.net.RequestPacker;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;

	use namespace xingcloud_internal;
	/**
	 * Action管理器，用于管理Action队列，合并请求并进行定量或定时的发送
	 *
	 */
	public class ActionManager implements IEventDispatcher
	{
		private static var _instance:ActionManager;

		/**
		 * 获取ActionManager实例
		 *
		 */
		public static function get instance():ActionManager
		{
			if (!_instance)
			{
				_instance=new ActionManager(new singleLock);
			}
			return _instance;
		}

		/**
		 *
		 * @private
		 *
		 */
		public function ActionManager(lock:singleLock)
		{
			packer=new RequestPacker("action.action.execute");
			packer.blocking=false;
		}

		private var packer:RequestPacker;

		/**
		 *Action请求是否需要阻塞，即在前一个请求返回前请求的发送不会被立即发送，而是缓存起来等待上一个请求返回后再进行发送
		 *
		 */
		public function set blocking(value:Boolean):void
		{
			packer.blocking=value;
		}

		/**
		 * 请求队列达到这个长度后就会向服务器发送,默认为5
		 * */
		public function set minLength(l:uint):void
		{
			packer.minLength=l;
		}

		/**
		 * 请求发送的最短时间周期,单位为毫秒，默认为2000
		 * */
		public function set minPeriod(p:uint):void
		{
			packer.minPeriod=p;
		}

		/**
		 *增加一个action到队列中
		 * @param action
		 *
		 */
		public function addAction(action:Action):void
		{
			packer.addRequest(action);
		}

		/**
		 *移除一个action到队列中
		 * @param action
		 *
		 */
		public function removeAction(action:Action):void
		{
			packer.removeRequest(action);
		}

		/**
		 *清除队列
		 *
		 */
		public function clear():void
		{
			packer.clear();
		}

		/**
		 *立即发送队列中的请求
		 *
		 */
		public function send():void
		{
			packer.send();
		}

		/**
		 * 停止发送
		 *
		 */
		public function stop():void
		{
			packer.stop();
		}

		public function addEventListener(type:String,
			listener:Function,
			useCapture:Boolean=false,
			priority:int=0,
			useWeakReference:Boolean=false):void
		{
			packer.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}

		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			packer.removeEventListener(type, listener, useCapture);
		}

		public function dispatchEvent(event:Event):Boolean
		{
			return packer.dispatchEvent(event);
		}

		public function hasEventListener(type:String):Boolean
		{
			return packer.hasEventListener(type);
		}

		public function willTrigger(type:String):Boolean
		{
			return packer.willTrigger(type);
		}
	}
}

internal class singleLock
{
}
