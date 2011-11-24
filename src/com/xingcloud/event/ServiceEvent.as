package com.xingcloud.event
{
	import com.xingcloud.services.Service;
	import flash.events.Event;

	public class ServiceEvent extends Event
	{
		public static const SERVICE_COMPLETE:String="service_complete";
		public static const SERVICE_ERROR:String="service_error";
		public static const SERIVCE_PROGRESS:String="service_progress";
		/**
		 * 用户登录成功
		 */
		public static const LOGIN_SUCCESS:String="login_success";
		/**
		 * 用户登录失败
		 */
		public static const LOGIN_ERROR:String="login_error";
		/**
		 *注册成功
		 */
		public static const REGISTER_SUCCESS:String="register_success";
		/**
		 *注册失败
		 */
		public static const REGISTER_ERROR:String="register_error";
		/**
		 * 档案获取成功
		 */
		public static const PROFILE_LOADED:String="get_profile_success";
		/**
		 * 档案获取失败
		 */
		public static const PROFILE_ERROR:String="get_profile_error";

		/**
		 * 物品详细信息加载成功
		 */
		public static const ITEM_LOAD_SUCCESS:String="item_load_success";
		/**
		 *物品详细信息加载失败
		 */
		public static const ITEM_LOAD_ERROR:String="item_load_error";

		public function ServiceEvent(type:String, s:Service, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_service=s;
		}

		private var _service:Service;

		override public function clone():Event
		{
			return new ServiceEvent(type, service, bubbles, cancelable);
		}

		/**
		 * 获取此事件相关服务
		 *
		 */
		public function get service():Service
		{
			return _service;
		}
	}
}
