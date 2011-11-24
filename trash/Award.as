package com.elex.users
{
	import com.elex.core.ELEX;
	import com.elex.core.elex_internal;
	import com.elex.items.owned.ItemsCollection;
	import com.elex.items.owned.OwnedItem;
	import com.elex.users.actions.IAction;

	import flash.utils.getDefinitionByName;

	use namespace elex_internal;

	/**
	 * 给用户的奖励，目前有三种奖励类型：经验，金钱和物品，更多的奖励措施自由扩展。。。
	 * */
	public class Award
	{
		/**
		 * 经验值奖励
		 * */
		public var exp:int=0;
		/**
		 * 金钱奖励
		 * */
		public var coins:int=0;
		/**
		 * 物品奖励，意指一个ownedItem物品类型，如CropItem
		 * */
		public var itemType:String;
		/**
		 * 物品的ItemSpec ID
		 * */
		public var itemId:String;
		/**
		 * 物品奖励个数
		 * */
		public var itemCount:uint=1;

		public function Award()
		{
		}

		public static function parseFromXML(xml:XML):Award
		{
			var award:Award=new Award();
			if (xml.hasOwnProperty("@exp"))
				award.exp=parseInt(xml.@exp);
			if (xml.hasOwnProperty("@coins"))
				award.coins=parseInt(xml.@coins);
			if (xml.hasOwnProperty("@itemType"))
				award.itemType=xml.@itemType;
			if (xml.hasOwnProperty("@itemCount"))
				award.itemCount=parseInt(xml.@itemCount);
			return award;
		}

		/**
		 * 提交一个奖励，参数action,successCall,failCall和AbstractUserProfile.track一样
		 * @param action:     是否提交后台，如果在submmit前已经调用了AbstractUserProfile.track，这些参数可以不用理会
		 * @param immediately:是否立即提交后台
		 * @param successCall:成功回调
		 * @param failCall:   失败回调
		 * */
		public function submmit(immediately:Boolean=false, successCall:Function=null, failCall:Function=null):void
		{
			if (exp == 0 && coins == 0 && itemType == null)
				return;
			if (ELEX.ownerUser)
			{
				ELEX.ownerUser.track( successCall, failCall);
				//向后台提交
				ELEX.ownerUser.coins+=this.coins;
				ELEX.ownerUser.exp+=this.exp;
				//增加奖励物品
				if (itemType)
				{
					var itemClsName:String=ELEX.ownerUser.getItemType(itemType);
					var itemsField:String=ELEX.ownerUser.getFieldByItemType(itemType);
					if (itemClsName)
						var itemCls:Class=getDefinitionByName(itemClsName) as Class;
					if (itemCls)
						var item:OwnedItem=new itemCls(itemId) as OwnedItem;
					if (item && ELEX.ownerUser.hasOwnProperty(itemsField))
					{
						item.count=itemCount;
						(ELEX.ownerUser[itemsField] as ItemsCollection).addItem(item);
					}
				}
				if ( immediately)
					ELEX.ownerUser.commit();
			}
		}
	}
}