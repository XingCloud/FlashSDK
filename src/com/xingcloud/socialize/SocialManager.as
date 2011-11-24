
package com.xingcloud.socialize
{
	import com.xingcloud.core.Config;
	import com.xingcloud.core.XingCloud;
	import com.xingcloud.core.xingcloud_internal;
	import com.xingcloud.tasks.SimpleTask;
	import com.xingcloud.util.Debug;
	import elex.socialize.ElexProxy;
	import elex.socialize.mode.IElexUser;
	import elex.socialize.mode.RequestResponder;
	import elex.socialize.requests.GetActiveUserProfileRequest;
	import elex.socialize.requests.GetAllFriendsProfilesRequest;
	import elex.socialize.requests.GetAppFriendsProfilesRequest;
	import elex.socialize.requests.GetAppIdRequest;
	import elex.socialize.requests.GetConfigXmlRequest;
	import elex.socialize.requests.GetSnsTypeRequest;
	import elex.socialize.requests.GetUidRequest;
	import elex.socialize.requests.GetUsersProfilesRequest;
	import elex.socialize.requests.InviteFriendsRequest;
	import elex.socialize.requests.PostFeedRequest;
	import elex.socialize.requests.PostMessageRequest;
	import elex.socialize.requests.ReloadGameRequest;
	import elex.socialize.requests.ShowPaymentRequest;
	import elex.socialize.utils.Console;

	use namespace xingcloud_internal;

	public class SocialManager
	{
		private static var _instance:SocialManager;

		public static function get instance():SocialManager
		{
			if (!_instance)
			{
				_instance=new SocialManager(new inlock);
			}
			return _instance;
		}

		public function SocialManager(lock:inlock)
		{
			executor=new SimpleTask();
			ElexProxy.instance.init(XingCloud.stage);
			executor.addExecute(getGameConfig, [getConfigCallBack, getConfigError], this);
			executor.addExecute(getUid, [onGetUidSuccess, onGetUidFail], this);
			executor.addExecute(getSnsType, [onGetSnsSuccess, onGetSnsFail], this);
			executor.addExecute(getAppid, [onGetAppidSuccess, onGetAppidFail], this);
			_needNum=0;
		}

		public var executor:SimpleTask;

		private var baseConfig:XML;
		private var _uid:String;
		private var _sns:String;
		private var _appId:String;
		private var _needNum:int;

		public function get connectToGDP():Boolean
		{
			var id:String=ElexProxy.instance.proxySession.connectId;
			return id != "" && id != null;
		}

		/**
		 * 获取所有好友信息,成功调用后返回的结果中包含<code>PlatformAccount</code>的列表
		 * @param onSuccess(result:SocialResult)
		 * @param onFail(error:SocialResult)
		 *
		 */
		public function getAllFriendsInfo(onSuccess:Function, onFail:Function):void
		{
			ElexProxy.instance.sendRequest(new GetAllFriendsProfilesRequest(function(result:RequestResponder):void
			{
				var oldinfo:Array=result.data;
				var info:Array=[];
				for each (var user:IElexUser in oldinfo)
				{
					var pa:PlatformAccount=new PlatformAccount();
					pa.user=user;
					info.push(pa);
				}
				result.data=info;
				var socialResult:SocialResult=new SocialResult();
				socialResult.responder=result;
				if (onSuccess != null)
					onSuccess(socialResult);
			}, function(error:RequestResponder):void
			{
				var socialResult:SocialResult=new SocialResult();
				socialResult.responder=error;
				if (onFail != null)
					onFail(socialResult);
			}));
		}

		/**
		 * 获取当前游戏好友信息,成功调用后返回的结果中包含<code>PlatformAccount</code>的列表
		 * @param onSuccess(result:SocialResult)
		 * @param onFail(error:SocialResult)
		 *
		 */
		public function getAppFriendsInfo(onSuccess:Function, onFail:Function):void
		{
			ElexProxy.instance.sendRequest(new GetAppFriendsProfilesRequest(function(result:RequestResponder):void
			{
				var oldinfo:Array=result.data;
				var info:Array=[];
				for each (var user:IElexUser in oldinfo)
				{
					var pa:PlatformAccount=new PlatformAccount();
					pa.user=user;
					info.push(pa);
				}
				result.data=info;
				var socialResult:SocialResult=new SocialResult();
				socialResult.responder=result;
				if (onSuccess != null)
					onSuccess(socialResult);
			}, function(error:RequestResponder):void
			{
				var socialResult:SocialResult=new SocialResult();
				socialResult.responder=error;
				if (onFail != null)
					onFail(socialResult);
			}));
		}

		/**
		 * 获取当前用户的信息,成功调用后返回的结果中包含当前用户的<code>PlatformAccount</code>信息
		 * @param onSuccess(result:SocialResult)
		 * @param onFail(error:SocialResult)
		 *
		 */
		public function getUserPlatformInfo(onSuccess:Function, onFail:Function):void
		{
			ElexProxy.instance.sendRequest(new GetActiveUserProfileRequest(function(result:RequestResponder):void
			{
				var pa:PlatformAccount=new PlatformAccount();
				pa.user=result.data;
				result.data=pa;
				var socialResult:SocialResult=new SocialResult();
				socialResult.responder=result;
				if (onSuccess != null)
					onSuccess(socialResult);
			}, function(error:RequestResponder):void
			{
				var socialResult:SocialResult=new SocialResult();
				socialResult.responder=error;
				if (onFail != null)
					onFail(socialResult);
			}));
		}

		/**
		 * 获取多个用户的信息,成功调用后返回的结果中包含<code>PlatformAccount</code>的列表
		 * @param uidList 查询用户的uid的列表
		 * @param onSuccess(result:SocialResult)
		 * @param onFail(error:SocialResult)
		 *
		 */
		public function getProfiles(uidList:Array, onSuccess:Function, onFail:Function):void
		{
			ElexProxy.instance.sendRequest(new GetUsersProfilesRequest(uidList, function(result:RequestResponder):void
			{
				var oldinfo:Array=result.data;
				var info:Array=[];
				for each (var user:IElexUser in oldinfo)
				{
					var pa:PlatformAccount=new PlatformAccount();
					pa.user=user;
					info.push(pa);
				}
				result.data=info;
				var socialResult:SocialResult=new SocialResult();
				socialResult.responder=result;
				if (onSuccess != null)
					onSuccess(socialResult);
			}, function(error:RequestResponder):void
			{
				var socialResult:SocialResult=new SocialResult();
				socialResult.responder=error;
				if (onFail != null)
					onFail(socialResult);
			}));
		}

		/**
		 * 发送feed.
		 * @param templateId feed模板的ID
		 * @param feed feed对象
		 * @param onSuccess(result:SocialResult)
		 * @param onFail(error:SocialResult)
		 *
		 */
		public function sendFeed(templateId:String, feed:Feed, onSuccess:Function, onFail:Function):void
		{
			ElexProxy.instance.sendRequest(new PostFeedRequest(templateId,
				feed.feed,
				function(result:RequestResponder):void
			{
				var socialResult:SocialResult=new SocialResult();
				socialResult.responder=result;
				if (onSuccess != null)
					onSuccess(socialResult);
			},
			function(error:RequestResponder):void
			{
				var socialResult:SocialResult=new SocialResult();
				socialResult.responder=error;
				if (onFail != null)
					onFail(socialResult);
			}));
		}

		/**
		 * 显示支付页面
		 * @param onSuccess(result:SocialResult)
		 * @param onFail(error:SocialResult)
		 *
		 */
		public function showPayments(onSuccess:Function, onFail:Function):void
		{
			ElexProxy.instance.sendRequest(new ShowPaymentRequest(function(result:RequestResponder):void
			{
				var socialResult:SocialResult=new SocialResult();
				socialResult.responder=result;
				if (onSuccess != null)
					onSuccess(socialResult);
			}, function(error:RequestResponder):void
			{
				var socialResult:SocialResult=new SocialResult();
				socialResult.responder=error;
				if (onFail != null)
					onFail(socialResult);
			}));
		}

		/**
		 *邀请朋友,调用弹出好友邀请窗口,成功后返回邀请朋友的UID数组
		 * @param onSuccess(result:SocialResult)
		 * @param onFail(error:SocialResult)
		 *
		 */
		public function inviteFriends(onSuccess:Function, onFail:Function):void
		{
			ElexProxy.instance.sendRequest(new InviteFriendsRequest(function(result:RequestResponder):void
			{
				var socialResult:SocialResult=new SocialResult();
				socialResult.responder=result;
				if (onSuccess != null)
					onSuccess(socialResult);
			}, function(error:RequestResponder):void
			{
				var socialResult:SocialResult=new SocialResult();
				socialResult.responder=error;
				if (onFail != null)
					onFail(socialResult);
			}));
		}

		/**
		 * 发送消息，发送成功后返回发送对象的UID数组
		 * @param templateId 消息模板ID
		 * @param feed feed对象
		 * @param onSuccess(result:SocialResult)
		 * @param onFail(error:SocialResult)
		 *
		 */
		public function postMessage(templateId:String, feed:Feed, onSuccess:Function, onFail:Function):void
		{
			ElexProxy.instance.sendRequest(new PostMessageRequest(templateId,
				feed.feed,
				function(result:RequestResponder):void
			{
				var socialResult:SocialResult=new SocialResult();
				socialResult.responder=result;
				if (onSuccess != null)
					onSuccess(socialResult);
			},
			function(error:RequestResponder):void
			{
				var socialResult:SocialResult=new SocialResult();
				socialResult.responder=error;
				if (onFail != null)
					onFail(socialResult);
			}));
		}

		/**
		 * 刷新页面重新加载游戏
		 *
		 */
		public function reLoadGame():void
		{
			ElexProxy.instance.sendRequest(new ReloadGameRequest());
		}

		/**
		 * 获取配置信息
		 *
		 */
		public function get gameConfig():XML
		{
			return baseConfig;
		}

		/**
		 * 获取SNS平台名称
		 *
		 */
		public function get sns():String
		{
			return _sns;
		}

		/**
		 * 获取用户的平台UID
		 *
		 */
		public function get uid():String
		{
			if (_uid)
				return _uid;
			else
				return Config.getConfig("sig_user");
		}

		public function get appId():String
		{
			if (_appId)
				return _appId;
			else
				return "xingcloudDebug";
		}

		private function getGameConfig(onSuccess:Function, onFail:Function):void
		{
			ElexProxy.instance.sendRequest(new GetConfigXmlRequest(onSuccess, onFail));
		}

		private function getUid(onSuccess:Function, onFail:Function):void
		{
			ElexProxy.instance.sendRequest(new GetUidRequest(onSuccess, onFail));
		}

		private function getAppid(onSuccess:Function, onFail:Function):void
		{
			ElexProxy.instance.sendRequest(new GetAppIdRequest(onSuccess, onFail));
		}

		private function getSnsType(onSuccess:Function, onFail:Function):void
		{
			ElexProxy.instance.sendRequest(new GetSnsTypeRequest(onSuccess, onFail));
		}

		private function getConfigCallBack(res:RequestResponder):void
		{
			try
			{
				baseConfig=new XML(res.data.toString());
				Config.parseFromXML(baseConfig);
				Debug.info("Get config successfully,result is " + baseConfig, this);
			}
			catch (e:Error)
			{
				baseConfig=null;
				Debug.error("Get config fail,result is " + res.data.toString(), this);
			}
			if (checkInitLoad())
				executor.taskComplete();
		}

		private function getConfigError(res:RequestResponder):void
		{
			baseConfig=null;
			Debug.error("Get config fail," + res.message, this);
			if (checkInitLoad())
				executor.taskError();
		}

		private function onGetSnsFail(res:RequestResponder):void
		{
			if (checkInitLoad())
				executor.taskError();
		}

		private function onGetSnsSuccess(res:RequestResponder):void
		{
			_sns=res.data.toString();
			if (checkInitLoad())
				executor.taskComplete();
		}

		private function onGetAppidSuccess(res:RequestResponder):void
		{
			_appId=res.data.toString();
			if (checkInitLoad())
				executor.taskComplete();
		}

		private function onGetAppidFail():void
		{
			if (checkInitLoad())
				executor.taskError();
		}

		private function onGetUidFail(res:RequestResponder):void
		{
			if (checkInitLoad())
				executor.taskError();
		}

		private function onGetUidSuccess(res:RequestResponder):void
		{
			_uid=res.data.toString();
			if (checkInitLoad())
				executor.taskComplete();
		}

		private function checkInitLoad():Boolean
		{
			_needNum++;
			if (_needNum == 4)
				return true;
			else
				return false;
		}
	}
}

internal class inlock
{
}
