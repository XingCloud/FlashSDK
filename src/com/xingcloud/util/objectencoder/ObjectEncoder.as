package com.xingcloud.util.objectencoder
{
	import com.smartfoxserver.v2.entities.data.SFSDataWrapper;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	import flash.utils.describeType;
	import mx.utils.ObjectUtil;

	/**
	 * 对一个对象进行编码操作，使其能够应用于相应的通信格式。
	 */
	public class ObjectEncoder
	{
		/**
		 * AMF格式，适用于AMF通信模式。
		 */
		public static const AMF:String="AMFComposite";
		/**
		 * JSON格式，适用于REST通信模式。
		 */
		public static const JSON:String="JSONComposite";
		/**
		 * SFSObjet格式，适用于SFS通信模式。
		 */
		public static const SFS:String="SFSComposite";

		/**
		 * 创建一个编码器，对对象进行编码操作。
		 * @param value 进行编码的对象
		 * @param encodeType 编码类型，有<code>ObjectEncoder.JSON</code><code>ObjectEncoder.AMF</code>
		 * 					 <code>ObjectEncoder.SFS</code>三种类型
		 * @param orderd 是否按照属性名进行排序
		 * @param complexType 需要解析的复杂类型（动态对象会进行解析）
		 */
		public function ObjectEncoder(value:Object, encodeType:String, orderd:Boolean=false, complexType:Array=null)
		{
			_encodeType=encodeType;
			_complexType=complexType;
			_orderd=orderd;
			switch (_encodeType)
			{
				case JSON:
					_compositor=new JSONComposite(this);
					break;
				case SFS:
					_compositor=new SFSComposite(this);
					break;
				case AMF:
					_compositor=new AMFComposite(this);
					break;
			}
			_result=convertTo(value);
		}

		private var _complexType:Object;
		private var _compositor:IComposite;

		private var _encodeType:String;
		private var _orderd:Boolean;
		private var _result:Object;

		/**
		 *获取AMF对象
		 */
		public function get AmfObject():Object
		{
			return _result as Object;
		}

		/**
		 *获取JSON字符串
		 */
		public function get JsonString():String
		{
			return _result as String;
		}

		/**
		 *获取SFS对象
		 */
		public function get SfsObject():SFSObject
		{
			return (_result as SFSDataWrapper).data;
		}


		/**
		 * 转换数组
		 * @private
		 */
		internal function arrayTo(a:Array):Object
		{
			var tempArray:Array=[];
			var length:int=a.length;
			for (var i:int=0; i < length; i++)
			{
				var temp:Object=a[i];
				if (needEncode(temp))
				{
					tempArray.push(temp);
				}
			}
			return _compositor.CompositeArray(tempArray);
		}

		/**
		 * 分类转换,跟据类型进行分别转换。
		 * @private
		 */
		internal function convertTo(value:*):*
		{
			if (value is String)
			{
				return _compositor.CompositeString(value);
			}
			else if (value is int)
			{
				return _compositor.CompositeInt(value);
			}
			else if (value is Number)
			{
				return _compositor.CompositeNumber(value);
			}
			else if (value is Boolean)
			{
				return _compositor.CompositeBoolean(value);
			}
			else if (value is Array)
			{
				return arrayTo(value as Array);
			}
			else if (value is Object && value != null)
			{
				return objectTo(value);
			}
			return _compositor.CompositeNull();
		}

		/**
		 * 转换对象
		 * @private
		 */
		internal function objectTo(o:Object):Object
		{
			var classInfo:XML=describeType(o);
			var temp:Array=[];
			var element:Object;
			var value:Object;
			if (classInfo.@name.toString() == "Object") //o is a dynymic Object
			{
				for (var key:String in o)
				{
					value=o[key];
					if (value is Function)
					{
						continue;
					}
					if (needEncode(value))
					{
						temp.push({key: key, value: value});
					}
				}
			}
			else // o is a class instance
			{
				var childList:XMLList=classInfo.children();
				for each (var v:XML in childList)
				{
					var tagName:String=v.localName();
					if (tagName == "variable" || (tagName == "accessor" && v.@access.charAt(0) == "r"))
					{
						if (v.metadata && v.metadata.(@name == "Transient").length() > 0)
						{
							continue;
						}
						value=o[v.@name];
						if (needEncode(value))
						{
							temp.push({key: v.@name.toString(), value: value});
						}
					}
				}
			}
			if (_orderd)
				temp.sortOn("key");
			return _compositor.CompositeObject(temp);
		}

		/**
		 *是否需要编码
		 * @private
		 */
		private function needEncode(element:Object):Boolean
		{
			if (element == null)
				return true;
			var need:Boolean=false;
			if (!ObjectUtil.isSimple(element) && !ObjectUtil.isDynamicObject(element))
			{
				for each (var type:Class in _complexType)
				{
					if (element is type)
					{
						need=true;
						break;
					}
				}
			}
			else
				need=true;
			return need;
		}
	}
}




