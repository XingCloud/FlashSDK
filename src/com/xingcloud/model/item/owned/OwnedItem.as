package com.xingcloud.model.item.owned
{
	import com.adobe.crypto.MD5;
	import com.xingcloud.core.XingCloud;
	import com.xingcloud.core.xingcloud_internal;
	import com.xingcloud.model.ModelBase;
	import com.xingcloud.model.item.spec.ItemSpec;
	import com.xingcloud.model.item.spec.ItemSpecManager;
	import com.xingcloud.util.Reflection;
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
	import mx.utils.UIDUtil;

	use namespace xingcloud_internal;

	/**
	 * 物品实例，用于表示游戏中实际存在的一个物品类。一个物品实例和一个ItemSpec相对应，在构造时使用itemId来标示。
	 */
	public class OwnedItem extends ModelBase
	{
		/**
		 *创建一个物品实例
		 * @param itemId 物品实例所对应的物品定义id
		 *
		 */
		public function OwnedItem(itemId:String)
		{
			_itemSpec=ItemSpecManager.instance.getItem(itemId);
			this.itemId=itemId;
			uid=generateUID(this);
		}

		/**
		 *拥有者ID
		 */
		public var ownerId:String;
		public var itemId:String;
		protected var ownerProperty:String="ownedItems";
		/**
		 *@private
		 */
		private var _itemSpec:ItemSpec;
		/**
		 *@private
		 */
		private var _uniqueString:String;

		/**
		 *从属的物品集
		 */
		public function get OwnerProperty():String
		{
			return ownerProperty;
		}


		/**
		 *从第三方数据源更新信息
		 * @param data 数据
		 * @param excluded 不需要更新的属性
		 *
		 */
		override public function parseFromObject(data:Object, excluded:Array=null):void
		{
			super.parseFromObject(data, excluded);
		}

		/**
		 * 此物品实例的定义
		 *
		 */
		public function get itemSpec():ItemSpec
		{
			return _itemSpec;
		}

		/**
		 *@private
		 */
		public function get uniqueString():String
		{
			return _uniqueString;
		}

		/**
		 * @private
		 */
		public function set uniqueString(value:String):void
		{
			_uniqueString=value;
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
			dispatchEvent(event);
		}

		private function generateUID(item:OwnedItem):String
		{
			var uniqueString:String=MD5.hash(UIDUtil.createUID() + "&" + Reflection.getAdress(item));
			item.uniqueString=uniqueString;
			return MD5.hash(XingCloud.uid + "&" + item.className + "&" + uniqueString);
		}
	}
}
