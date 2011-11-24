package com.xingcloud.model
{
	import com.xingcloud.core.xingcloud_internal;
	import com.xingcloud.util.Reflection;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.describeType;
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;

	/**
	 *基础数据模型类
	 *
	 */
	public class ModelBase extends EventDispatcher
	{
		private static var _dispatcher:EventDispatcher=new EventDispatcher();

		xingcloud_internal static function get dispatcher():EventDispatcher
		{
			return _dispatcher;
		}

		/**
		 *数据模型
		 *
		 */
		public function ModelBase()
		{
			super();
		}

		private var _uid:String;

		/**
		 * 此类的名称
		 * */
		public function get className():String
		{
			return Reflection.tinyClassName(this);
		}

		/**
		 *从一个Object中解析出此实例。根据实例的已存在属性来解析Object。
		 * @param data 数据源
		 * @param excluded 不用解析的字段集合
		 *
		 */
		public function parseFromObject(data:Object, excluded:Array=null):void
		{
			Reflection.cloneProperties(data, this, excluded);
		}

		/**
		 * 唯一Id
		 */
		public function get uid():String
		{
			return _uid;
		}

		public function set uid(uid:String):void
		{
			if (uid != _uid)
			{
				this._uid=uid;
			}
		}

		xingcloud_internal function toPlainObject():Object
		{
			var classInfo:XML=describeType(this);
			var plain:Object={};
			var value:Object;
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
					value=this[v.@name];
					if (value is ModelBase && value.uid)
					{
						plain[v.@name.toString()]=value.uid;
					}
					else
					{
						plain[v.@name.toString()]=value;
					}
				}
			}

			return plain;
		}
	}
}
