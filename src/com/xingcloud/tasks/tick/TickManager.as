package com.xingcloud.tasks.tick
{
	import com.xingcloud.core.xingcloud_internal;
	import flash.display.Sprite;
	import flash.events.Event;

	/**
	 * 用于统一管理具有帧驱动事件的对象
	 *
	 */
	public class TickManager
	{
		private static var _tickQueue:Array=[];

		/**
		 *增加一个循环调用器
		 * @param t 循环执行器
		 * @return 添加是否成功，如果已存在则添加失败
		 */
		public static function addTick(t:ITick):Boolean
		{
			var index:int=_tickQueue.indexOf(t);
			if (index == -1)
			{
				_tickQueue.push(t);
				return true;
			}
			else
			{
				return false;
			}
		}

		/**
		 *清空循环调用器队列
		 *
		 */
		public static function clearTick():void
		{
			_tickQueue=[];
		}

		/**
		 * 移除一个循环调用器
		 * @param t 循环调用器
		 * @return 移除是否成功，如果不存在则移除失败
		 */
		public static function removeTick(t:ITick):Boolean
		{
			var index:int=_tickQueue.indexOf(t);
			if (index != -1)
			{
				_tickQueue.splice(index, 1);
				return true;
			}
			else
			{
				return false;
			}
		}

		xingcloud_internal static function init(app:Sprite):void
		{
			app.addEventListener(Event.ENTER_FRAME, onTick);
		}

		private static function onTick(e:Event):void
		{
			for each (var t:ITick in _tickQueue)
			{
				t.tick();
			}
		}

		public function TickManager()
		{
		}
	}
}
