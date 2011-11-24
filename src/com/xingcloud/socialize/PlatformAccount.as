package com.xingcloud.socialize
{
	import com.xingcloud.core.xingcloud_internal;
	import elex.socialize.mode.ElexUser;
	import elex.socialize.mode.IElexUser;

	/**
	 * 平台账户信息,储存当前接入平台的账户相关信息
	 *
	 */
	public class PlatformAccount
	{
		/**
		 * 新建一个平台账户
		 * @param userId 平台用户ID
		 * @param gender 用户性别
		 * @param headerImgUrl 平台头像URL
		 * @param userName 平台用户名称
		 *
		 */
		public function PlatformAccount()
		{
		}

		private var _user:IElexUser

		/**
		 * 平台用户ID
		 *
		 */
		public function get userId():String
		{
			if (_user)
				return _user.id;
			else
				return "";
		}

		/**
		 * 平台用户名称
		 *
		 */
		public function get name():String
		{
			if (_user)
				return _user.name;
			else
				return "";
		}

		/**
		 * 平台头像URL
		 *
		 */
		public function get avatar():String
		{
			if (_user)
				return _user.avatar;
			else
				return "";
		}

		internal function set user(u:IElexUser):void //使用GDP的对象赋值
		{
			_user=u;
		}

		xingcloud_internal function setDebugData(userid:String, username:String, headerurl:String):void
		{
			_user=new ElexUser(userid, username, headerurl, null);
		}
	}
}
