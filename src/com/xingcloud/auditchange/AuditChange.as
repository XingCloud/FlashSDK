package com.xingcloud.auditchange
{
	import com.xingcloud.core.XingCloud;
	import com.xingcloud.core.xingcloud_internal;
	import com.xingcloud.net.IPackableRequest;
	import com.xingcloud.util.Reflection;

	/**
	 * 用于记录用户数据的变更
	 * @private
	 */
	public class AuditChange implements IPackableRequest
	{
		public function AuditChange(params:Object=null)
		{
			_params=params;
		}

		/**
		 *缓存哪些对象发生了变更，用于服务器返回数据后的数据更新处理
		 */
		public var changeField:Object={};

		public var onSuccess:Function=null;
		public var onFail:Function=null;

		/**
		 *变化的列表
		 */
		public var changes:Array=[];
		protected var _failCount:int;
		private var _params:Object;
		private var _name:String;

		public function handleDataBack(result:Object):void
		{
			AuditChangeManager.instance.stopTrack();
			if (result.code == 200)
			{
				for each (var change:Object in result.data)
				{
					updateAuditChangeData(change);
				}
				if (onSuccess != null)
					onSuccess(result);
			}
			else
			{
				if (_failCount < 3)
				{
					AuditChangeManager.instance.addAudit(this);
					_failCount++;
				}
				else
				{
					if (onFail != null)
						onFail(result);
				}
			}
		}

		public function get data():Object
		{
			return {name: name, changes: changes, params: _params};
		}

		/**
		 *返回AuditChange的名称
		 * @return
		 *
		 */
		public function get name():String
		{
			return Reflection.tinyClassName(this);
		}


		//统一处理服务器返回的变更
		private function updateAuditChangeData(data:Object):void
		{
			if (data.hasOwnProperty("className") && changeField[data.className])
			{
				changeField[data.className].parseFromObject(data);
				if (data.className != "UserProfile")
				{
					if (changeField[data.className].uid == null)
					{
						var field:String=changeField[data.className].ownerProperty;
						changeField[data.className].xingcloud_internal::owner[field].updateItemUID(changeField[data.className]);
					}
				}
			}
		}
	}
}
