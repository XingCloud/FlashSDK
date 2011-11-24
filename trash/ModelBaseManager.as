package com.xingcloud.model
{
	import com.adobe.crypto.MD5;
	import com.xingcloud.auditchange.AuditChangeManager;
	import com.xingcloud.core.XingCloud;
	import com.xingcloud.core.xingcloud_internal;
	import com.xingcloud.model.item.owned.ItemsCollection;
	import com.xingcloud.model.item.owned.OwnedItem;
	import com.xingcloud.model.users.AbstractUserProfile;
	import com.xingcloud.util.Reflection;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	import mx.events.CollectionEvent;
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
	import mx.utils.ObjectProxy;
	import mx.utils.UIDUtil;

	use namespace xingcloud_internal;

	/**
	 * 模型对象池
	 * @private
	 */
	public class ModelBaseManager
	{
		private static var _instance:ModelBaseManager;

		public static function get instance():ModelBaseManager
		{
			if (!_instance)
			{
				_instance=new ModelBaseManager();
			}
			return _instance;
		}

		public function ModelBaseManager()
		{
			pool=new Dictionary();
			dispatch=new EventDispatcher();
		}

		private var dispatch:EventDispatcher;

		private var pool:Dictionary;

		/**
		 *对OwnedItem生成UID，同时设置OwnedItem的uniqueString，此uniqueString是用于生成UID的唯一标示
		 * @param item 需要生成UID的OwnedItem
		 * @return 生成的UID
		 *
		 */
		xingcloud_internal function generateUID(item:OwnedItem):String
		{
			var uniqueString:String=MD5.hash(UIDUtil.createUID() + "&" + Reflection.getAdress(item));
			item.uniqueString=uniqueString;
			return MD5.hash(XingCloud.uid + "&" + item.className + "&" + uniqueString);
		}

		xingcloud_internal function putModel(modelbase:ModelBase):Boolean
		{
			if (modelbase.uid)
			{
				pool[modelbase.uid]=modelbase;
				modelbase.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onPropertyChanged);
				if (modelbase is AbstractUserProfile)
				{
					for each (var items:ItemsCollection in(modelbase as AbstractUserProfile).itemsBulk)
					{
						items.addEventListener(CollectionEvent.COLLECTION_CHANGE, onItemsChange);
					}
				}
				return true;
			}
			else
				return false;
		}

		xingcloud_internal function removeModel(uid:String):void
		{
			if (pool[uid])
			{
				pool[uid].removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onPropertyChanged);
				delete pool[uid];
			}
		}

		xingcloud_internal function getModel(uid:String):ModelBase
		{
			return pool[uid];
		}

		xingcloud_internal function updateModel(modelbase:ModelBase, newUID:String):void
		{
			if (pool[modelbase.uid])
			{
				pool[newUID]=modelbase;
				pool[modelbase.uid].removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onPropertyChanged);
				delete pool[modelbase.uid];
			}
		}

		/**
		 * 创建OwnedItem,如果不指定uid则生成uid
		 *
		 */
		xingcloud_internal function createModelItem(type:String, itemID:String):OwnedItem
		{
			if (type.indexOf(".") == -1)
			{
				type="model.owneditem." + type;
			}
			var cls:Class=Reflection.getClassByName(type);
			if (cls == null)
				return null;
			var item:OwnedItem=new cls(itemID) as OwnedItem;
			item.uid=generateUID(item);
			return item;
		}


		private function onPropertyChanged(e:PropertyChangeEvent):void
		{
			var newValue:Object=e.newValue;
			var oldValue:Object=e.oldValue;
			if (newValue is ModelBase)
				newValue=(newValue as ModelBase).toPlainObject();
			if (oldValue is ModelBase)
				oldValue=(oldValue as ModelBase).toPlainObject();
			AuditChangeManager.instance.appendUpdateChange(e.target as ModelBase,
				e.property.toString(),
				oldValue,
				newValue);
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
						AuditChangeManager.instance.appendItemAddChange(item as OwnedItem);
						break;
//					case "update":
//						var propEvt:PropertyChangeEvent=item as PropertyChangeEvent;
//						appendUpdateChange(propEvt.source as OwnedItem,
//							propEvt.property.toString(),
//							propEvt.oldValue,
//							propEvt.newValue);
//						break;
					case "remove":
						AuditChangeManager.instance.appendItemRemoveChange(item as OwnedItem);
						break;
				}
			}
		}
	}
}
