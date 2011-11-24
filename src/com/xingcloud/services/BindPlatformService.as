package com.xingcloud.services
{
	import com.xingcloud.core.Config;
	import com.xingcloud.core.xingcloud_internal;
	use namespace xingcloud_internal;
	public class BindPlatformService extends Service
	{
		/**
		 *需要和当前游戏ID绑定的平台列表
		 * @param platformList 包括一个或多个{platformAppId:,platformUserId:}对象的数组，
		 * 每一对platformAppId和platformUserId标示一个平台
		 *
		 */
		public function BindPlatformService(platformList:Array, onSuccess:Function=null, onFail:Function=null)
		{
			super(onSuccess, onFail);
			_commandArgs=platformList;
			_commandName=Config.BIND_PLATFORM_SERVICE;
		}
	}
}
