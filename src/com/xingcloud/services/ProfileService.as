package com.xingcloud.services
{
	import com.xingcloud.core.Config;
	import com.xingcloud.core.XingCloud;
	import com.xingcloud.event.ServiceEvent;
	import com.xingcloud.model.users.AbstractUserProfile;
	import com.xingcloud.net.connector.Connector;
	import com.xingcloud.tasks.Task;
	import com.xingcloud.tasks.TaskEvent;
	import com.xingcloud.core.xingcloud_internal;
	use namespace xingcloud_internal;
	/**
	 * 用户档案获取服务，可以获取多个用户的档案信息，获取成功后通过<code>profileData</code>
	 * 获取数据列表
	 *
	 */
	public class ProfileService extends Service
	{
		/**
		 *实例化一个加载用户档案的服务
		 * @param profileList 需要加载的用户列表，可以是一个或多个
		 *
		 */
		public function ProfileService(profileList:Array, onSuccess:Function=null, onFail:Function=null)
		{
			super(onSuccess, onFail);
			var platformIds:Array=[];
			var gameIds:Array=[];
			for each (var user:AbstractUserProfile in profileList)
			{
				if (user.uid)
				{
					gameIds.push({gameUserId: user.uid});
				}
				else
				{
					platformIds.push({platformAppId: Config.platformAppId, platformUserId: user.platformAccount.userId});
				}
			}
			_commandName=Config.USERPROFILE_SERVICE;
			_commandArgs=platformIds.concat(gameIds);
			_profileList=profileList;
		}

		private var _profileList:Array;

		private var _profileData:Array;

		/**
		 * 在服务调用成功后，获取到的档案数据列表
		 *
		 */
		public function get profileData():Array
		{
			return _profileData;
		}

		override protected function onComplete(event:TaskEvent):void
		{
			_profileData=event.target.data.data;
			for (var i:int=0; i < _profileList.length; i++)
			{
				if (_profileData[i])
				{
					(_profileList[i] as AbstractUserProfile).parseFromObject(_profileData[i]);
				}
			}
			_result=event.target.data;
			if (_onSuccess != null)
				_onSuccess(this);
			ServiceManager.instance.dispatchEvent(new ServiceEvent(ServiceEvent.PROFILE_LOADED, this));
		}

		override protected function onError(event:TaskEvent):void
		{
			_result=event.target.data;
			if (_onFail != null)
				_onFail(this);
			ServiceManager.instance.dispatchEvent(new ServiceEvent(ServiceEvent.PROFILE_ERROR, this));
		}
	}
}
