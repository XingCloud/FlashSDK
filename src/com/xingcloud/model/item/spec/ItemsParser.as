package com.xingcloud.model.item.spec
{
	import com.adobe.serialization.json.JSON;
	import com.xingcloud.util.Debug;
	import com.xingcloud.util.Reflection;
	import flash.geom.Point;
	import flash.utils.Dictionary;

	/**
	 *物品定义解析
	 * @private
	 * */
	internal class ItemsParser
	{
		private static const defaultItemClass:Class=ItemSpec;
		private static const defaultGroupClass:Class=ItemGroup;

		private static var _xml:XML;
		private static var _itemsManager:ItemSpecManager=ItemSpecManager.instance;
		/**
		 * 不需要复制的属性
		 * */
		private static const excludedParentAtrrs:Array=["id", "name"];

		/**
		 * 从xml描述中解析物品
		 * */
		public static function parse(source:XML):void
		{
			_itemsManager.source=source;
			_xml=_itemsManager.source;
			parseProperties(_itemsManager, _xml);
			parseBody();

		}

		/**
		 * 将xml定义的xml属性解析到target对象中
		 * */
		public static function parseProperties(target:*, xml:XML):void
		{
			for each (var attr:XML in xml.attributes())
			{
				parseProperty(target, attr);
			}
		}

		/**
		 * 将一个xml属性赋值给对象target
		 * @param target:任何对象，如果对象具有属性值，则按照类型赋值，否则赋值成string
		 * @param attr:一个xml属性，如<item type="spec"/> type="spec"是要处理的对象
		 * */
		public static function parseProperty(target:*, attr:XML):void
		{
			var key:String=attr.localName();
			var val:String=attr.toString();
			var keyExists:Boolean=target.hasOwnProperty(key);
			if (keyExists)
			{
				var p:Object=target[key];
				if (p is Number)
					target[key]=Number(val);
				else if (p is int)
					target[key]=parseInt(val);
				else if (p is Boolean)
					target[key]=parseBoolean(val);
				else if (p is Array)
					target[key]=parseArray(val);
				else if (p is Point)
					target[key]=parsePoint(val);
				else if (p is Dictionary)
					target[key]=parseDictionary(val);
				else if (p is String)
					target[key]=val;
				else if (Reflection.tinyClassName(p) == "Object")
					target[key]=parseObject(val);
				else
					target[key]=val;
			}
		}

		/**
		 * 将以‘，’分开的字符串转成Point
		 * **/
		public static function parsePoint(attr:String):Point
		{
			var p:Point=new Point();
			var attrArr:Array=attr.split(",");
			p.x=Number(attrArr[0]);
			if (attrArr.length > 1)
				p.y=Number(attrArr[1]);
			return p;
		}

		/**
		 * 将JSON格式或以‘，’分开的字符串转成string数组
		 * **/
		public static function parseArray(attr:String):Array
		{
			try
			{
				return JSON.decode(attr);
			}
			catch (e:Error)
			{
				var p:Array=[];
				var attrArr:Array=attr.split(",");
				for (var i:int=0; i < attrArr.length; i++)
				{
					p[i]=attrArr[i];
				}
				return p;
			}
			return [];
		}

		/**
		 * 转化布尔型
		 *
		 */
		public static function parseBoolean(str:String):Boolean
		{
			var originalString:String=str;

			if (str != null)
			{
				str=str.toLowerCase();
				if (str == "true" || str == "1")
				{
					return true;
				}
				else if (str == "false" || str == "0")
				{
					return false;
				}
			}
			return (str != null) && (str.length > 0);
		}

		/**
		 *转化之举有单层结构的对象，储存元素为String
		 *
		 */
		public static function parseObject(val:String):Object
		{
			var obj:Object;
			try
			{
				obj=JSON.decode(val);
			}
			catch (e:Error)
			{
				Debug.error("Can't parse Ojbect from definition '" + val + "'.");
			}
			return obj;
		}

		/**
		 * 转化只具有单程结构的字典类型，储存元素为String
		 *
		 */
		public static function parseDictionary(val:String):Dictionary
		{
			var dic:Dictionary=new Dictionary();
			try
			{
				var obj:Object=JSON.decode(val);
				for (var key:String in obj)
				{
					dic[key]=obj[key];
				}
			}
			catch (e:Error)
			{
				Debug.error("Can't parse Dictionary from definition '" + val + "'.");
			}
			return dic;
		}


		protected static function parseBody():void
		{
			//物品分组列表，组以group为节点
			var groupList:XMLList=_xml.children(); //.group;
			var len:uint=groupList.length();
			for (var i:int=0; i < len; i++)
			{
				var group:ItemGroup=new ItemGroup();
				parseChild(group, groupList[i] as XML);
				_itemsManager.addGroup(group);
			}
		}

		/**
		 * itemSpec的定义规则
		 * id   作为数据库关键字，必须，
		 * name 可选，可同名，没有则取id
		 * */
		protected static function parseProps(target:ItemBase, xml:XML=null):void
		{
			if (xml == null)
				xml=target.xml;
			parseProperties(target, xml);
			if (target.id == null)
				Debug.error("The item " + target.xml + " must have a id property!");
			if (target.name == null)
				target.name=target.id;
		}

		/**如果有父节点，将父节点所有可复制属性赋值给子节点，然后再解析子节点自己定义的属性，
		 * 目的是父节点定义的属性会覆盖到所有没有定义该属性的子节点，这对于需要定义一组物品的共同属性很有用
		 * */
		private static function parseChild(item:ItemBase, xml:XML, parent:ItemGroup=null):void
		{
			item.xml=xml;

			if (parent)
				copyParentProps(item, parent);
			parseProps(item);
			if (!(item is ItemGroup))
				return;
			var children:XMLList=item.xml.children();
			var len:uint=children.length();
			for (var i:int=0; i < len; i++)
			{
				var itemXml:XML=children[i];
				var model:ItemBase=getModel(itemXml);
				if (model == null)
				{
					throw new Error("The database xml is not validated!");
				}
				parseChild(model, itemXml, item as ItemGroup);
				(item as ItemGroup).addItem(model);
			}
		}

		/**
		 * 节点只要包含group字符，我们视为group类型，如果没有找到对应类，用默认的ItemGroup，
		 * 节点只要包含item字符，我们视为item类型，如果没有找到对应类，用默认的ItemSpec
		 * */
		private static function getModel(xml:XML):ItemBase
		{
			var clsName:String=xml.attribute("class").toString();
			var cls:Class=Reflection.getClassByName("model.item.itemspec." + clsName);
			if (cls == null)
			{
				if (isGroupType(xml))
				{
					cls=defaultGroupClass;
				}
				else if (isItemType(xml))
				{
					cls=defaultItemClass;
				}
				else
				{
					throw new Error("The class " + clsName + " is not defined!");
				}
			}
			return new cls() as ItemBase;


		}

		private static function isGroupType(xml:XML):Boolean
		{
			var node:String=String(xml.localName()).toLowerCase();
			return (node == "group"); //(node.indexOf("group")>=0);
		}

		private static function isItemType(xml:XML):Boolean
		{
			var node:String=String(xml.localName()).toLowerCase();
			return (node.indexOf("itemspec") >= 0);
		}

		/**
		 * 从父节点获取属性
		 * */
		private static function copyParentProps(child:ItemBase, parent:ItemGroup):void
		{
			for each (var attr:XML in parent.xml.attributes())
			{
				var attrName:String=attr.localName();
				if ((excludedParentAtrrs.indexOf(attrName) == -1))
				{
					parseProperty(child, attr);
				}
			}
		}
	}
}
