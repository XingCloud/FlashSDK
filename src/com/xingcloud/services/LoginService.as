package com.xingcloud.services
{
	import com.adobe.crypto.MD5;
	import com.xingcloud.core.Config;
	import com.xingcloud.core.XingCloud;
	import com.xingcloud.core.xingcloud_internal;
	import com.xingcloud.event.ServiceEvent;
	import com.xingcloud.model.users.AbstractUserProfile;
	import com.xingcloud.tasks.TaskEvent;
	import com.xingcloud.util.Reflection;
	
	import flash.utils.getDefinitionByName;

	use namespace xingcloud_internal;
	/**
	 * 登陆服务，使用用户名密码进行登陆的服务，并在登陆成功后获取登陆用户的UserProfile
	 *
	 */
	public class LoginService extends Service
	{

		public function LoginService(username:String, password:String, onSuccess:Function=null, onFail:Function=null)
		{
			super(onSuccess, onFail);
			_commandName=Config.LOGIN_SERVICE;
			_commandArgs={username: username, password: MD5.hash(password)};
		}

		private var _userprofile:AbstractUserProfile;

		/**
		 *用户档案，在登陆成功的事件派发后方可取得
		 * @return 登陆用户的档案
		 *
		 */
		public function get userprofile():AbstractUserProfile
		{
			return _userprofile;
		}

		override protected function onComplete(event:TaskEvent):void
		{
			_result=event.target.data;
			Config.setConfig("sig_user", _result.data.username);
			XingCloud.uid=_result.data.uid;
			var def:Class=Reflection.getClassByName("model.user.UserProfile");
			if(def)
			{
				_userprofile=new def() as AbstractUserProfile;
			}
			else
			{
				_userprofile=new AbstractUserProfile();
			}
			_userprofile.parseFromObject(_result.data);
			if (_onSuccess != null)
				_onSuccess(this);
			ServiceManager.instance.dispatchEvent(new ServiceEvent(ServiceEvent.LOGIN_SUCCESS, this));
		}

		override protected function onError(event:TaskEvent):void
		{
			_result=event.target.data;
			if (_onFail != null)
				_onFail(this);
			ServiceManager.instance.dispatchEvent(new ServiceEvent(ServiceEvent.LOGIN_ERROR, this));

		}
	}
}
