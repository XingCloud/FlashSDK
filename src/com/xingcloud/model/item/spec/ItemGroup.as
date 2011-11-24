package com.xingcloud.model.item.spec
{

	/**
	* 定义一个物品组，这个定义无需继承，他是动态类，可以赋值任何自定义itemSpec属性，
	* 当子元素设此属性时忽略，子元素没设此属性时，用此属性赋值之，可以方便的设置整组物品的一些通用属性
	* */
	public dynamic final class ItemGroup extends ItemBase
	{

		public function ItemGroup()
		{
			super();
			_children=[];
		}

		protected var _children:Array;

		/**
		 *在物品组内增加一个物品定义
		 * @param itm 物品定义
		 *
		 */
		public function addItem(itm:ItemBase):void
		{
			if (this.contains(itm))
			{
				return;
			}
			_children[this.length]=itm;
			itm.parent=this;
		}

		/**
		 *在物品组内移除一个物品定义
		 * @param itm 物品定义
		 * @return 是否移除成功
		 *
		 */
		public function removeItem(itm:ItemBase):Boolean
		{
			var i:int=_children.indexOf(itm);
			if (i > -1)
			{
				_children.splice(i, 1);
				itm.parent=null;
				return true;
			}
			return false;
		}

		/**
		 *获取特定id的物品定义
		 * @param id 物品定义id
		 * @param deepSearch 如果子元素是group，是否继续向下搜寻
		 * @return 物品定义
		 *
		 */
		public function getItem(id:String, deepSearch:Boolean=true):ItemSpec
		{
			var len:uint=_children.length;
			for (var i:int=0; i < len; i++)
			{
				var itm:ItemBase=_children[i];
				if ((itm is ItemSpec) && (id == (itm as ItemSpec).id))
					return itm as ItemSpec;
				if (deepSearch && (itm is ItemGroup))
				{
					var ri:ItemSpec=(itm as ItemGroup).getItem(id);
					if (ri)
						return ri;
				}
			}
			return null;
		}

		/**
		 *获取特定名称的物品定义
		 * @param name 物品名称
		 * @param deapSearch  如果子元素是group，是否继续向下搜寻
		 * **/
		public function getItemByName(name:String, deepSearch:Boolean=true):ItemSpec
		{
			var len:uint=_children.length;
			for (var i:int=0; i < len; i++)
			{
				var item:ItemBase=_children[i];
				if ((name == item.name) && (item is ItemSpec))
					return item as ItemSpec;
				if (deepSearch && (item is ItemGroup))
				{
					var ri:ItemSpec=(item as ItemGroup).getItemByName(name);
					if (ri)
						return ri;
				}
			}
			return null;
		}

		/**
		 * 获取当前group下所有的items
		 *  @param deapSearch: 如果子元素是group，是否寻找底层的item
		 *  @param arr: 赋值给他
		 * **/
		public function getAllItems(deepSearch:Boolean=false, arr:Array=null):Array
		{
			if (arr == null)
				arr=[];
			var len:uint=_children.length;
			for (var i:int=0; i < len; i++)
			{
				var itm:ItemBase=_children[i];
				if (itm is ItemSpec)
				{
					arr.push(itm);
				}
				else if (deepSearch)
				{
					(itm as ItemGroup).getAllItems(true, arr);
				}
			}
			return arr;
		}

		/**
		 * 获取为group类型的所有子元素，只在当前层
		 * **/
		public function getAllGroups():Array
		{
			var arr:Array=[];
			var len:uint=_children.length;
			for (var i:int=0; i < len; i++)
			{
				var itm:ItemBase=_children[i];
				if (itm is ItemGroup)
				{
					arr.push(itm);
				}
			}
			return arr;
		}

		/**
		 *获取特定id的物品定义组
		 * @param id groupid
		 * @param deepSearch 是否深度搜索
		 * @return
		 *
		 */
		public function getChildGroup(id:String, deepSearch:Boolean=true):ItemGroup
		{
			var len:uint=_children.length;
			for (var i:int=0; i < len; i++)
			{
				var itm:ItemBase=_children[i];
				if (itm is ItemGroup)
				{
					if ((itm as ItemGroup).id == id)
						return itm as ItemGroup;
					if (deepSearch)
					{
						var g:ItemGroup=(itm as ItemGroup).getChildGroup(id);
						if (g)
							return g;
					}
				}
			}
			return null;
		}

		/**
		 *对每个元素调用callBack函数
		 * @param callBack 调用的函数
		 *
		 */
		public function foreachItem(callBack:Function):void
		{
			var len:uint=_children.length;
			for (var i:int=0; i < len; i++)
			{
				var item:ItemBase=_children[i];
				callBack(item);
			}
		}

		/**
		 *是否包含此元素
		 * @param itm
		 * @return
		 *
		 */
		public function contains(itm:ItemBase):Boolean
		{
			var len:uint=_children.length;
			for (var i:int=0; i < len; i++)
			{
				var item:ItemBase=_children[i];
				if (item.id == itm.id)
				{
					return true;
				}
			}
			return false;
		}

		/**
		 *group长度
		 * @return
		 *
		 */
		public function get length():int
		{
			return _children.length;
		}

		/**
		 * 所有子元素，包括ItemSpec和所有嵌套的itemGroup
		 * */
		public function get children():Array
		{
			var arr:Array=[];
			for each (var item:ItemBase in _children)
			{
				arr.push(item);
			}
			return arr;
		}
	}
}
