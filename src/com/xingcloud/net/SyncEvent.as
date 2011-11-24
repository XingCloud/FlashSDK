package com.xingcloud.net
{
	import flash.events.Event;

	/**
	 * 与后台同步数据事件
	 *
	 */
	public class SyncEvent extends Event
	{
		/**
		 * 同步开始事件
		 */
		public static const SYNC_START:String="sync_start";
		/**
		 *同步完成事件
		 */
		public static const SYNC_COMPLETE:String="sync_complete";
		/**
		 *同步重试事件
		 */
		public static const SYNC_RETYR:String="sync_retry";
		/**
		 *同步失败事件，当多次尝试后返回同步失败事件时，则前后台数据不同步，需重新处理
		 */
		public static const SYNC_ERROR:String="sync_error";

		public function SyncEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}
