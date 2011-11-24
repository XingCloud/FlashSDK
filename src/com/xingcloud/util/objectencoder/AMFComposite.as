package com.xingcloud.util.objectencoder
{

	public class AMFComposite implements IComposite
	{
		/**
		 *创建一个AMF组装器
		 * @param encoder 应用的解析器
		 *
		 */
		public function AMFComposite(encoder:ObjectEncoder)
		{
			_encoder=encoder;
		}

		private var _encoder:ObjectEncoder;

		public function CompositeArray(a:Array):*
		{
			var comarray:Array=[];
			for each (var item:* in a)
			{
				comarray.push(_encoder.convertTo(item));
			}
			return comarray;
		}

		public function CompositeBoolean(b:Boolean):*
		{
			return b;
		}

		public function CompositeInt(i:int):*
		{
			return i;
		}

		public function CompositeNull():*
		{
			return "";
		}

		public function CompositeNumber(n:Number):*
		{
			return n;
		}

		public function CompositeObject(o:Array):*
		{
			if(o.length==0)
				return "";
			var comObject:Object={};
			for each (var item:Object in o)
			{
				comObject[item.key]=_encoder.convertTo(item.value);
			}
			return comObject;
		}

		public function CompositeString(s:String):*
		{
			return s;
		}
	}
}
