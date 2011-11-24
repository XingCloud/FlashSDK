package com.xingcloud.auditchange
{
	import com.xingcloud.core.Config;
	import com.xingcloud.core.xingcloud_internal;
	import com.xingcloud.model.ModelBase;
	import com.xingcloud.model.item.owned.OwnedItem;
	import com.xingcloud.net.RequestPacker;
	import com.xingcloud.net.SyncEvent;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import mx.events.CollectionEvent;
	import mx.events.PropertyChangeEvent;

	use namespace xingcloud_internal;

	/**
	 *同步开始时进行派发
	 * @eventType com.xingcloud.net.SyncEvent
	 */
	[Event(type="com.xingcloud.net.SyncEvent", name="sync_start")]
	/**
	 *同步完成时进行派发
	 * @eventType com.xingcloud.net.SyncEvent
	 */
	[Event(type="com.xingcloud.net.SyncEvent", name="sync_complete")]
	/**
	 *同步重试时派发
	 * @eventType com.xingcloud.net.SyncEvent
	 */
	[Event(type="com.xingcloud.net.SyncEvent", name="sync_retry")]
	/**
	 *同步失败时派发
	 * @eventType com.xingcloud.net.SyncEvent
	 */
	[Event(type="com.xingcloud.net.SyncEvent", name="sync_error")]
	/**
	 *变更记录管理器,用于记录用户的操作
	 *@private
	 */
	public class AuditChangeManager implements IEventDispatcher
	{
		private static var _instance:AuditChangeManager;

		public static function get instance():AuditChangeManager
		{
			if (!_instance)
			{
				_instance=new AuditChangeManager(new singleLock);
			}
			return _instance;
		}

		/**
		 * @private
		 */
		public function AuditChangeManager(singleLock:singleLock)
		{
			packer=new RequestPacker(Config.AUDIT_SERVICE);
			packer.blocking=true;
			packer.addEventListener(SyncEvent.SYNC_START, onStartSync);
			ModelBase.dispatcher.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onPropertyChanged);
			ModelBase.dispatcher.addEventListener(CollectionEvent.COLLECTION_CHANGE, onItemsChange);
		}

		private var _currentAudit:AuditChange;

		private var packer:RequestPacker;

		/**
		 * 请求队列达到这个长度后就会向服务器发送,默认为5
		 * */
		public function set minLength(l:uint):void
		{
			packer.minLength=l;
		}

		/**
		 * 请求发送的最短时间周期,单位为毫秒，默认为2000
		 * */
		public function set minPeriod(p:uint):void
		{
			packer.minPeriod=p;
		}

		/**
		 * 开始记录变更
		 * @param auditChange 记录的auditchange
		 * @param successCallback 成功后的调用函数
		 * @param failCallback 失败后的调用函数
		 *
		 */
		public function track(auditChange:AuditChange, successCallback:Function=null, failCallback:Function=null):AuditChange
		{
			_currentAudit=auditChange;
			_currentAudit.onSuccess=successCallback
			_currentAudit.onFail=failCallback;
			addAudit(_currentAudit);
			return _currentAudit;
		}

		/**
		 * 停止记录变更
		 *
		 */
		public function stopTrack():void
		{
			_currentAudit=null;
		}

		/**立即提交改变到服务器**/
		public function send():void
		{
			packer.send();
		}

		/**
		 * 停止自动发送进程
		 * */
		public function stop():void
		{
			packer.stop();
		}

		/**
		 * 清楚队列消息
		 *
		 */
		public function clear():void
		{
			packer.clear();
		}

		/**
		 *增加一个变更记录
		 * @param audit
		 *
		 */
		public function addAudit(audit:AuditChange):void
		{
			packer.addRequest(audit);
		}

		/**
		 *移除一个变更记录
		 * @param auditz
		 *
		 */
		public function removeAudit(audit:AuditChange):void
		{
			packer.removeRequest(audit);
		}

		/**
		 *获取当前 变更记录
		 * @return
		 *
		 */
		public function get currentAudit():AuditChange
		{
			return _currentAudit;
		}

		/**
		 * 当前是否有指定的audit可用
		 * */
		public function get canUse():Boolean
		{
			return _currentAudit != null;
		}

		public function addEventListener(type:String,
			listener:Function,
			useCapture:Boolean=false,
			priority:int=0,
			useWeakReference:Boolean=false):void
		{
			packer.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}

		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			packer.removeEventListener(type, listener, useCapture);
		}

		public function dispatchEvent(event:Event):Boolean
		{
			return packer.dispatchEvent(event);
		}

		public function hasEventListener(type:String):Boolean
		{
			return packer.hasEventListener(type);
		}

		public function willTrigger(type:String):Boolean
		{
			return packer.willTrigger(type);
		}

		private function onPropertyChanged(e:PropertyChangeEvent):void
		{
			var newValue:Object=e.newValue;
			var oldValue:Object=e.oldValue;
			appendUpdateChange(e.source as ModelBase, e.property.toString(), oldValue, newValue);
		}

		private function onItemsChange(e:CollectionEvent):void
		{
			var items:Array=e.items;
			var length:int=items.length;
			for (var i:int=0; i < length; i++)
			{
				var item:Object=items[i];
				switch (e.kind)
				{
					case "add":
						appendItemAddChange(item as OwnedItem);
						break;
					case "update":
						onPropertyChanged(item as PropertyChangeEvent);
						break;
					case "remove":
						appendItemRemoveChange(item as OwnedItem);
						break;
				}
			}
		}

		/**
		 * 添加一个属性改变，后台会直接改变数据库
		 * @param item:      要改变属性的实例对象，UserInfoBase的子类，如UserProfile,OwnedItem等
		 * @param property:  要改变的属性名
		 * @param oldValue:  改变前的值
		 * @param newValue:  改变后的值
		 * */
		private function appendUpdateChange(item:ModelBase, property:String, oldValue:Object, newValue:Object):Boolean
		{
			if (!canUse)
				return false;
			var change:Object={target: item.className, method: "update", uid: item.uid, property: property,
					 oldValue: oldValue, newValue: newValue};
			var duplicate:Object=checkSamePropChange(change);
			if (duplicate) //有重复，更新新值
			{
				duplicate.newValue=change.newValue;
			}
			else
			{
				_currentAudit.changeField[item.className]=item;
				_currentAudit.changes.push(change);
			}
			return true;
		}

		/**
		 * 要添加一条记录，后台会直接改变数据库
		 * @param item:      新物品
		 * */
		private function appendItemAddChange(item:OwnedItem):Boolean
		{
			if (!canUse)
				return false;
			_currentAudit.changes.push({target: item.className, method: "add", item: item});
			_currentAudit.changeField[item.className]=item;
			return true;
		}

		/**
		 * 要删除一条记录，后台会直接改变数据库
		 * @param item:   要删除的物品
		 * */
		private function appendItemRemoveChange(item:OwnedItem):Boolean
		{
			if (!canUse)
				return false;
			_currentAudit.changes.push({target: item.className, method: "remove", uid: item.uid});
			_currentAudit.changeField[item.className]=item;
			return true;
		}

		private function onStartSync(event:SyncEvent):void
		{
			_currentAudit=null;
		}



		private function checkSamePropChange(chg:Object):Object
		{
			for (var i:int=0; i < _currentAudit.changes.length; i++)
			{
				var change:Object=_currentAudit.changes[i];
				if ((chg.target == change.target) && (chg.method == change.method) && (chg.uid == change.uid) && (chg.property == change.property))
				{
					return change;
				}
			}
			return null;
		}
	}
}

internal class singleLock
{
}
