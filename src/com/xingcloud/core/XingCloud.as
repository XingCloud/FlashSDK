package com.xingcloud.core
{
	import com.xingcloud.event.XingCloudEvent;
	import com.xingcloud.loader.DataLoader;
	import com.xingcloud.loader.ResourceType;
	import com.xingcloud.net.connector.RESTConnector;
	import com.xingcloud.services.StatusManager;
	import com.xingcloud.tasks.CompositeTask;
	import com.xingcloud.tasks.SerialTask;
	import com.xingcloud.tasks.Task;
	import com.xingcloud.tasks.TaskEvent;
	import com.xingcloud.tasks.tick.TickManager;
	import com.xingcloud.util.Reflection;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.system.ApplicationDomain;
	import flash.system.Security;

	use namespace xingcloud_internal;

	/**
	 * 在行云SDK初始化完毕后进行派发。
	 * @eventType com.xingcloud.core.XingCloudEvent
	 */
	[Event(name="init_success", type="com.xingcloud.event.XingCloudEvent")]
	/**
	 * 在行云SDK初始化完毕后进行派发。
	 * @eventType com.xingcloud.core.XingCloudEvent
	 */
	[Event(name="init_error", type="com.xingcloud.event.XingCloudEvent")]
	/**
	 *  <code>XingCloud</code> 类是行云SDK的核心，用于初始化和功能配置工作，同时提供了必要的功能接口。
	 */
	public class XingCloud extends EventDispatcher
	{

		/**
		 * 默认远程通信方法类,用于无缝切换行云封装的远程请求的通信方法。如果用户扩展的远程请求需要无缝切换，请使用此类来进行构造，
		 * 构造函数参数为CommandName,CommandArg,needAuth，分别为请求接口名称，请求参数，是否需要安全验证，其中第三个参数可以使用
		 * <code>XingCloud.needAuth</code>来进行统一开关。
		 * @default RESTConnector
		 * @see XingCloud.needAuth
		 */
		public static var defaultConnector:Class=RESTConnector;


		/**
		 * 是否在和后台的交互中使用安全验证。
		 * @default true
		 */
		public static var needAuth:Boolean=true;
		/**
		 *请求数据是否需要压缩
		 * @default true
		 */
		public static var needCompress:Boolean=true;
		/**
		 *是否在登录成功后自动加载用户物品的详情。
		 * @see com.xingcloud.model.item.owned.ItemsCollection#load()
		 * @default true
		 */
		public static var autoLoadItems:Boolean=true;
		/**
		 * 当前用户在游戏中的唯一标示uid
		 */
		public static var uid:String;

		private static var _instance:XingCloud;

		/**
		 *取得<code>XingCloud</code>的唯一实例。
		 */
		public static function get instance():XingCloud
		{
			if (_instance == null)
				_instance=new XingCloud();
			return _instance;
		}

		/**
		 * 检测是否运行在本地环境
		 */
		public static function get isLocal():Boolean
		{
			return Security.sandboxType != Security.REMOTE;
		}

		/**
		 *获取主程序舞台
		 * @return  舞台实例
		 *
		 */
		public static function get stage():Stage
		{
			if (instance && instance.app)
				return instance.app.stage;
			else
				return null;
		}

		public function XingCloud()
		{
			if (_instance != null)
				throw new Error("XingCloud is singleton, use XingCloud.instance to get the instance!");
			_instance=this;
		}

		private var _app:Sprite;

		/**
		 *获取主程序容器
		 */
		public function get app():Sprite
		{
			return _app;
		}

		/**
		 * 初始化行云框架，获取游戏基本配置信息。行云初始化完成后将会派发<code>XingCloudEvent.INIT_SUCCESS</code>事件。
		 * 后续操作如服务、GDP等等需要在事件派发之后才可以使用。
		 * @param app 程序根容器
		 * @param configPath 外部自定义配置文件url
		 */
		public function init(app:Sprite, GDPData:Object=null):void
		{
			_app=app;
			Security.allowDomain("*");
			TickManager.init(_app);
			Reflection.addApplicationDomain(ApplicationDomain.currentDomain);
			Config.init(GDPData);
			var initTask:SerialTask=new SerialTask();
			var status:Task=StatusManager.instance.executor;
			status.name="获取服务状态信息";
			initTask.enqueue(status);

			initTask.addEventListener(TaskEvent.TASK_COMPLETE, onConfigComplete);
			initTask.addEventListener(TaskEvent.TASK_ERROR, onConfigError);
			initTask.addEventListener(TaskEvent.TASK_PROGRESS, onConfigProgress);
			initTask.execute();
		}

		protected function onConfigComplete(event:TaskEvent):void
		{
			event.task.removeEventListener(TaskEvent.TASK_COMPLETE, onConfigComplete);
			event.task.removeEventListener(TaskEvent.TASK_ERROR, onConfigError);
			event.task.removeEventListener(TaskEvent.TASK_PROGRESS, onConfigProgress);
			if (!Config.gateWay)
			{
				dispatchEvent(new XingCloudEvent(XingCloudEvent.INIT_ERROR, null, "gateway is missing."));
				return;
			}
			dispatchEvent(new XingCloudEvent(XingCloudEvent.INIT_SUCCESS, event.task as CompositeTask));
		}

		protected function onConfigError(event:TaskEvent):void
		{
			event.task.removeEventListener(TaskEvent.TASK_COMPLETE, onConfigComplete);
			event.task.removeEventListener(TaskEvent.TASK_ERROR, onConfigError);
			event.task.removeEventListener(TaskEvent.TASK_PROGRESS, onConfigProgress);
			dispatchEvent(new XingCloudEvent(XingCloudEvent.INIT_ERROR, event.task as CompositeTask, "初始化失败"));
		}

		protected function onConfigProgress(event:TaskEvent):void
		{
			dispatchEvent(new XingCloudEvent(XingCloudEvent.INIT_PROGRESS, event.task as CompositeTask));
		}
	}
}

import com.xingcloud.core.Config;
import com.xingcloud.core.XingCloud;
import com.xingcloud.core.xingcloud_internal;
import com.xingcloud.event.XingCloudEvent;
import com.xingcloud.loader.DataLoader;
import com.xingcloud.loader.ResourceType;

import flash.events.Event;

use namespace xingcloud_internal;

internal class ConfigLoader extends DataLoader
{
	public function ConfigLoader(url:String)
	{
		super(url, ResourceType.XML_DATA_FORMAT);
	}

	override protected function onCompleteHandler(evt:Event):void
	{
		Config.parseFromXML(new XML(_loader.data));
		if (!Config.gateWay)
		{
			XingCloud.instance.dispatchEvent(new XingCloudEvent(XingCloudEvent.INIT_ERROR, null, "gateway is missing."));
			return;
		}
		super.onCompleteHandler(evt);
	}
}
