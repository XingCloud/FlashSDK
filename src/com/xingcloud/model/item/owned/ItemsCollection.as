package com.xingcloud.model.item.owned
{
	import com.xingcloud.core.xingcloud_internal;
	import com.xingcloud.event.ServiceEvent;
	import com.xingcloud.model.users.AbstractUserProfile;
	import com.xingcloud.services.ItemsCollectionService;
	import com.xingcloud.services.ServiceManager;
	import com.xingcloud.util.Reflection;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import mx.collections.ArrayCollection;

	use namespace xingcloud_internal;

	[Event(name="item_load_success", type="com.xingcloud.event.ServiceEvent")]
	[Event(name="item_load_error", type="com.xingcloud.event.ServiceEvent")]
	public class ItemsCollection extends ArrayCollection
	{
		/**
		 *物品实例集合,用于储存一类物品实例
		 * @param source
		 *
		 */
		public function ItemsCollection(source:Array=null)
		{
			super(source);
		}

		public var ownerProperty:String="ownedItems";
		protected var itemsMap:Dictionary=new Dictionary();

		/**
		 * 是否需要加载详细信息
		 * */
		xingcloud_internal var needLoad:Boolean;

		/**此数组只允许itemType制定的class名作为元素，防止误操作,会严格考虑类型，继承的类都不算**/
		xingcloud_internal var itemType:String;
		/**此组物品属于哪个玩家***/
		xingcloud_internal var owner:AbstractUserProfile;
		private var _itemClass:Class;

		/**
		 *从服务器加载物品的详细信息
		 * <p>向服务器请求物品详细的信息，如果此物品集合有信息可以加载，则返回true，并向服务器进行请求，
		 * 成功后派发<code>XingCloudEvent.ITEM_LOAD_SUCCESS</code>事件
		 * 失败后派发<code>XingCloudEvent.ITEM_LOAD_ERROR</code>事件
		 * 返回false，并直接调用successCallback回调函数</p>
		 * @return 如果需要加载则返回true,如果不需要则返回false
		 *
		 */
		public function load():Boolean
		{
			if (!needLoad)
			{
				return false;
			}
			ServiceManager.instance.send(new ItemsCollectionService(this, onDataUpdated, onDataUpdateFail));
			return true;
		}

		/**
		 *移除一个物品
		 * @param item 物品
		 * @return  返回此物品
		 *
		 */
		public function removeItem(item:OwnedItem):OwnedItem
		{
			var index:int=this.getItemIndex(item);
			if (index == -1)
				return null;
			delete itemsMap[item.uid];
			return this.removeItemAt(index) as OwnedItem;
		}

		/**
		 *通过UID返回具体物品实例
		 * @param uid 物品uid
		 *
		 */
		public function getItemByUID(uid:String):OwnedItem
		{
			return itemsMap[uid];
		}

		/**
		 * 更新item的uid，使之可以查询。一般用于新增物品之后的处理
		 * @param item
		 * @return
		 *
		 */
		public function updateItemUID(item:OwnedItem):OwnedItem
		{
			itemsMap[item.uid]=item;
			return item;
		}

		/**
		 *增加一个物品
		 * @param item 物品
		 * @param index 插入的位置
		 *
		 */
		override public function addItemAt(item:Object, index:int):void
		{
			this.checkType(item);
			if (item.uid != null)
				itemsMap[item.uid]=item;
			super.addItemAt(item, index);
		}

		override public function addItem(item:Object):void
		{
			this.checkType(item);
			item.ownerId=owner.uid;
			if (item.uid != null)
				itemsMap[item.uid]=item;
			super.addItem(item);
		}

		public function updateItem(item:OwnedItem):void
		{
			var oldItem:OwnedItem=getItemByUID(item.uid);
			if (oldItem)
			{
				removeItem(oldItem);
			}
			addItem(item);
		}

		protected function onDataUpdated(s:ItemsCollectionService):void
		{
			var result:Object=s.itemscollectionData;
			this.removeAll();
			for each (var itemData:Object in result)
			{
				var item:OwnedItem=new itemClass(itemData.itemId);
				item.uid=itemData.uid;
				item.parseFromObject(itemData);
				this.addItem(item);
			}
			needLoad=false;
			this.dispatchEvent(new ServiceEvent(ServiceEvent.ITEM_LOAD_SUCCESS, s));
		}

		protected function onDataUpdateFail(s:ItemsCollectionService):void
		{
			this.dispatchEvent(new ServiceEvent(ServiceEvent.ITEM_LOAD_ERROR, s));
		}

		protected function get itemClass():Class
		{
			if (_itemClass == null)
				_itemClass=getDefinitionByName(this.itemType) as Class
			return _itemClass;
		}

		/**严格检查元素类型**/
		protected function checkType(item:Object):void
		{
			var className:String=Reflection.fullClassName(item);
			if (className != itemType)
			{
				throw new Error("The itemType must be " + this.itemType + " only, the inherited class is not permitted!");
			}
		}
	}
}
