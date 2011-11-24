package com.xingcloud.util.objectencoder
{
	import com.smartfoxserver.v2.entities.data.SFSArray;
	import com.smartfoxserver.v2.entities.data.SFSDataType;
	import com.smartfoxserver.v2.entities.data.SFSDataWrapper;
	import com.smartfoxserver.v2.entities.data.SFSObject;

	public class SFSComposite implements IComposite
	{
		/**
		 *创建一个SFS组装器
		 * @param encoder 应用的解析器
		 *
		 */
		public function SFSComposite(encoder:ObjectEncoder)
		{
			_encoder=encoder;
		}

		private var _encoder:ObjectEncoder;

		public function CompositeArray(a:Array):*
		{
			var sfsArray:SFSArray=new SFSArray();
			for each (var item:* in a)
			{
				sfsArray.add(_encoder.convertTo(item));
			}
			return new SFSDataWrapper(SFSDataType.SFS_ARRAY, sfsArray);
		}

		public function CompositeBoolean(b:Boolean):*
		{
			return new SFSDataWrapper(SFSDataType.BOOL, b);
		}

		public function CompositeInt(i:int):*
		{
			return new SFSDataWrapper(SFSDataType.INT, i);
		}

		public function CompositeNull():*
		{
			return new SFSDataWrapper(SFSDataType.NULL, null);
		}

		public function CompositeNumber(n:Number):*
		{
			return new SFSDataWrapper(SFSDataType.DOUBLE, n);
		}

		public function CompositeObject(o:Array):*
		{
			var sfsObject:SFSObject=new SFSObject();
			for each (var item:Object in o)
			{
				sfsObject.put(item.key, _encoder.convertTo(item.value));
			}
			return new SFSDataWrapper(SFSDataType.SFS_OBJECT, sfsObject);
		}

		public function CompositeString(s:String):*
		{
			return new SFSDataWrapper(SFSDataType.UTF_STRING, s);
		}
	}
}
