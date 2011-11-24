package com.xingcloud.services
{
	import com.xingcloud.core.Config;
	import com.xingcloud.core.XingCloud;
	import com.xingcloud.event.ServiceEvent;
	import com.xingcloud.model.item.owned.ItemsCollection;
	import com.xingcloud.tasks.TaskEvent;
	import com.xingcloud.core.xingcloud_internal;
	use namespace xingcloud_internal;
	public class ItemsCollectionService extends Service
	{
		public function ItemsCollectionService(ic:ItemsCollection, onSuccess:Function=null, onFail:Function=null)
		{
			super(onSuccess, onFail);
			_commandName=Config.ITEMSLOAD_SERVICE;
			_commandArgs={user_uid: XingCloud.uid, property: ic.ownerProperty};
		}

		private var _itemscollectionData:Object;

		public function get itemscollectionData():Object
		{
			return _itemscollectionData;
		}

		override protected function onComplete(event:TaskEvent):void
		{
			_result=event.target.data;
			_itemscollectionData=_result.data;
			if (_onSuccess != null)
				_onSuccess(this);
			ServiceManager.instance.dispatchEvent(new ServiceEvent(ServiceEvent.ITEM_LOAD_SUCCESS, this));
		}

		override protected function onError(event:TaskEvent):void
		{
			_result=event.target.data;
			if (_onFail != null)
				_onFail(this);
			ServiceManager.instance.dispatchEvent(new ServiceEvent(ServiceEvent.ITEM_LOAD_ERROR, this));
		}
	}
}
