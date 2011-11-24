package com.elex.core.config
{
	import com.elex.tasks.net.AMFConnectTask;
	import com.elex.users.AbstractUserProfile;
	import com.elex.users.actions.ActionManager;
	
	import elex.socialize.ISocializeContainer;
	
	import flash.utils.getTimer;

	/**
	 * 游戏一些常用的参数，我们把它集中到一起
	 * */
	public class Global
	{
		/**
		 * default ActionManager service ,then ActionManager.php will be located at 'Core' package
		 * this property will not be customed by developer
		 * */
		public static const ACTION_SERVICE:String="Core.ActionManager.execute";
		/**
		 * default UserProfile parent service,then UserProfile.php will be located at 'model->profile' package
		 * this property may be customed by developer
		 * */
		public static var USERPROFILE_SERVICE:String="model.profile";
		/**
		 *当前玩家信息,是否采用覆盖UserProfile的方式，todo
		 * */
		public static var ownerUser:AbstractUserProfile;
		
		public static function init(__socialContainer:ISocializeContainer=null,__socialConfig:XML=null):void
		{
			_socialContainer=__socialContainer;
			if(__socialConfig!=null) Config.parseFromXML(__socialConfig);
			//从ConfigManager初始化各项参数
			initConfig();
			//初始化gateway
			if(gateway==null) trace("Global->init: ","If you want to use backend,please use <ConfigManager.setConfig('gateway','your gateway')> firstly!");
			else AMFConnectTask.defaultGateway=gateway;
			//初始化ActionManager
			ActionManager.init(Global.ACTION_SERVICE);
		}
		/**
		 * 以下是特定的配置字段，一般是在GDP里配置的，如果要本地调试，请自行设置
		 * 如果没有指定gateway/assets/database，按以下约定：
		 *    webbase/front/main.swf里是游戏客服端主文件
		 *           /front/assets/里放置图像声音素材
		 *           /front/database.xml里放置database文件
		 *    webbase/back/gateway.php 是amfphp的gateway
		 * */
		private static function initConfig():void
		{
			_webbase=Config.getConfig("webbase");
			_gateway=Config.getConfig("gateway");
			_assets=Config.getConfig("assets");
			_database=Config.getConfig("database");
			_help=Config.getConfig("help");
		}
		private static var _socialContainer:ISocializeContainer;
		/**
		 * 获取social平台信息的container
		 * */
		public static function get socialContainer():ISocializeContainer
		{
			return _socialContainer;
		}
		private static var _webbase:String;
		private static var _gateway:String;
		private static var _assets:String;
		private static var _database:String;
		private static var _help:String;
		/**
		 * 游戏放置的根目录
		 * */
		public static function get webbase():String
		{
			return _webbase;
		}
		/**
		 * gateway地址
		 * */
		public static function get gateway():String
		{
			if(_gateway!=null) return _gateway;
			if(_webbase) return _webbase+"/back/gateway.php";
			return null;
		}
		/**
		 * 所有图像声音资源的放置目录
		 * */
		public static function get assets():String
		{
			if(_assets!=null) return _assets;
			if(_webbase) return _webbase+"/front/assets/";
			return null;
		}
		/**
		 * database.xml的放置目录
		 * */
		public static function get database():String
		{
			if(_database!=null) return _database;
			if(_webbase) return _webbase+"/front/";
			return null;
		}
		/**
		 * 帮助页面地址
		 * */
		public static function get help():String
		{
			return _help;
		}
        /**
		 * 要传到后台的必备参数,xa_target/plateform_sig_api_key都是后台约定
		 * */
		public static function get appInfo():Object
		{
			var targetName:String=Config.getConfig("xa_target");
			var publishID:String=Config.getConfig("plateform_sig_api_key");
			return {userID:ownerUser.uid,target:targetName,publishID:publishID};
		}
		/**
		 * 进行时间同步时的值,todo,在请求服务器时记得同步一下
		 */
		private static var _syncTime:Number=0;
		private static var _serverTime:Number = 0;
		/**
		 *从服务器获得的，后台标准的系统时间,是从1970年1月1日0时0秒至今的毫秒数。 
		 */		
		public static function get systemTime():Number
		{
			return getTimer() -_syncTime + _serverTime;
		}
		
		public static function set systemTime(time:Number):void
		{
			_serverTime = time;
			_syncTime = getTimer();
		}
	}
}