package com.xingcloud.model.users
{
	import com.xingcloud.core.XingCloud;
	import com.xingcloud.core.xingcloud_internal;
	import com.xingcloud.event.ServiceEvent;
	import com.xingcloud.model.ModelBase;
	import com.xingcloud.model.item.owned.ItemsCollection;
	import com.xingcloud.model.item.owned.OwnedItem;
	import com.xingcloud.services.ProfileService;
	import com.xingcloud.services.ServiceManager;
	import com.xingcloud.socialize.PlatformAccount;
	import mx.events.CollectionEvent;
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;

	use namespace xingcloud_internal;

	/**
	 * 在UserProfile信息成功加载后进行派发。
	 * @eventType com.xingcloud.core.ServiceEvent
	 */
	[Event(name="get_profile_success", type="com.xingcloud.event.ServiceEvent")]
	/**
	 * 在UserProfile信息加载出错后进行派发。
	 * @eventType com.xingcloud.core.ServiceEvent
	 */
	[Event(name="get_profile_error", type="com.xingcloud.event.ServiceEvent")]
	/**
	 * 物品加载成功后进行派发。
	 * @eventType com.xingcloud.core.ServiceEvent
	 */
	[Event(name="item_load_success", type="com.xingcloud.event.ServiceEvent")]
	/**
	 * 物品加载失败后进行派发
	 * @eventType com.xingcloud.core.ServiceEvent
	 */
	[Event(name="item_load_error", type="com.xingcloud.event.ServiceEvent")]
	/**
	 * 用户信息基类
	 */
	public class AbstractUserProfile extends ModelBase
	{
		/**
		 *用户信息
		 * @param isOwner 是否是用户本身
		 * @param autoLogin 是否自动登录，缺省为是
		 * @param changeMode 是否打开auditChange模式，缺省为是
		 *
		 */
		public function AbstractUserProfile()
		{
			createItemCollection();
		}

		/**
		 * 一个UserProfile可能包含多种ownedItem
		 * */
		public var ownedItems:ItemsCollection=new ItemsCollection();
		/**
		 * 用户物品实例集合
		 */
		xingcloud_internal var itemsBulk:Array=[];

		private var _coin:uint;
		private var _money:uint;
		private var _experience:uint;
		private var _level:uint;

		private var _platformAccount:PlatformAccount;
		private var itemFields:Array=[]; //物品集的字段名记录
		private var loadedNum:int;
		private var needLoadNum:int;

		public function get isOwner():Boolean
		{
			return uid == XingCloud.uid;
		}

		/**
		 * 加载用户信息。如果操作当前用户。
		 */
		public function load():void
		{
			ServiceManager.instance.send(new ProfileService([this], onProfileLoaded, onProfileError));
		}

		override public function parseFromObject(data:Object, excluded:Array=null):void
		{
			super.parseFromObject(data, itemFields);
			for each (var key:String in itemFields)
			{
				(this[key] as ItemsCollection).needLoad=(data[key] != null);
			}
		}

		/**
		 *加载用户物品详情
		 * @return 是否需要加载，true则需要，false则不需要
		 *
		 */
		public function loadOwnedItemDetail():Boolean
		{
			needLoadNum=0;
			loadedNum=0;
			for each (var items:ItemsCollection in itemsBulk)
			{
				if (items.load())
				{
					items.addEventListener(ServiceEvent.ITEM_LOAD_SUCCESS, onItemsLoaded);
					items.addEventListener(ServiceEvent.ITEM_LOAD_ERROR, onItemsLoadedError);
					needLoadNum++;
				}
			}
			if (needLoadNum == 0)
				return false;
			else
				return true;
		}

		public function addItem(item:OwnedItem):void
		{
			var collection:ItemsCollection=this[item.OwnerProperty] as ItemsCollection;
			collection.addItem(item);
		}

		public function updateItem(item:OwnedItem):void
		{
			var collection:ItemsCollection=this[item.OwnerProperty] as ItemsCollection;
			collection.updateItem(item);
		}

		public function removeItem(item:OwnedItem):void
		{
			var collection:ItemsCollection=this[item.OwnerProperty] as ItemsCollection;
			collection.removeItem(item);
		}

		public function getItem(uid:String):OwnedItem
		{
			for each (var collection:ItemsCollection in itemsBulk)
			{
				var item:OwnedItem=collection.getItemByUID(uid);
				if (item)
					return item;
			}
			return null;
		}

		/**
		 *平台账户信息,由GDP获取
		 */
		public function get platformAccount():PlatformAccount
		{
			return _platformAccount;
		}

		public function get level():uint
		{
			return _level;
		}

		public function set level(value:uint):void
		{
			if (value != _level)
			{
				propertyUpdate("level", _level, value);
				_level=value;
			}

		}

		public function get coin():uint
		{
			return _coin;
		}

		public function set coin(value:uint):void
		{
			if (value != _coin)
			{
				propertyUpdate("coin", _coin, value);
				_coin=value;
			}

		}

		public function get money():uint
		{
			return _money;
		}

		public function set money(value:uint):void
		{
			if (value != _money)
			{
				propertyUpdate("money", _money, value);
				_money=value;
			}
		}

		public function get experience():uint
		{
			return _experience;
		}

		public function set experience(value:uint):void
		{
			if (value != _experience)
			{
				propertyUpdate("experience", _experience, value);
				_experience=value;
			}
		}

		protected function createItemCollection():void
		{
			this.addCollection("ownedItems", "com.xingcloud.items.owned.OwnedItem");
		}

		/**
		 * 添加一个ownedItems和ownedItem的映射，IDE自动完成
		 * @param name: items字段的名字，如ownedItems
		 * @param itemType: items对应的ownedItem类名，全路径
		 * */
		protected function addCollection(name:String, itemType:String):void
		{
			itemFields.push(name);
			var items:ItemsCollection=this[name] as ItemsCollection;
			items.itemType=itemType;
			var dex:int=itemType.lastIndexOf(".");
			items.ownerProperty=name;
			items.owner=this;
			itemsBulk.push(items);
			items.addEventListener(CollectionEvent.COLLECTION_CHANGE, onCollectionChange);
		}

		xingcloud_internal function propertyUpdate(property:String, oldValue:Object, newValue:Object):void
		{
			var event:PropertyChangeEvent=new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE,
				false,
				false,
				PropertyChangeEventKind.UPDATE,
				property,
				oldValue,
				newValue,
				this);
			ModelBase.dispatcher.dispatchEvent(event);
		}

		xingcloud_internal function specifyPlatformAccount(value:PlatformAccount):void
		{
			_platformAccount=value;
		}

		private function onCollectionChange(event:CollectionEvent):void
		{
			ModelBase.dispatcher.dispatchEvent(event);
		}



		private function onProfileLoaded(s:ProfileService):void
		{
			this.dispatchEvent(new ServiceEvent(ServiceEvent.PROFILE_LOADED, s));
			if (XingCloud.autoLoadItems)
			{
				if (!loadOwnedItemDetail())
					dispatchEvent(new ServiceEvent(ServiceEvent.ITEM_LOAD_SUCCESS, null));
			}
		}

		private function onProfileError(s:ProfileService):void
		{
			this.dispatchEvent(new ServiceEvent(ServiceEvent.PROFILE_ERROR, s));
		}

		private function onItemsLoaded(evt:ServiceEvent):void
		{
			loadedNum++;
			if (loadedNum == needLoadNum)
			{
				dispatchEvent(new ServiceEvent(ServiceEvent.ITEM_LOAD_SUCCESS, null));
			}
		}

		private function onItemsLoadedError(evt:ServiceEvent):void
		{
			dispatchEvent(new ServiceEvent(ServiceEvent.ITEM_LOAD_ERROR, null));
		}
	}
}
