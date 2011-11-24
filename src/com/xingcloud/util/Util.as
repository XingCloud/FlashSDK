package com.xingcloud.util
{
	import flash.utils.ByteArray;

	public class Util
	{
		private static var uniqueId:Number=1;

		public static function get messageId():Number
		{
			return uniqueId++;
		}

		public static function compressTextData(data:String):ByteArray
		{
			var bytes:ByteArray=new ByteArray();
			bytes.writeUTFBytes(data);
			bytes.compress();
			return bytes;
		}

		public static function unCompressData(data:ByteArray, isText:Boolean=true):*
		{
			data.uncompress();
			data.position=0;
			if (isText)
				return data.readUTFBytes(data.length);
			else
				return data;
		}

		public function Util()
		{
		}
	}
}
