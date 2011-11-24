package com.xingcloud.net.loader {
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;

	/**
	 * @author longyangxi
	 */
	public class BinaryLoader extends DataLoader {
		public function BinaryLoader(urlOrRequest:*) {
			super(urlOrRequest, URLLoaderDataFormat.BINARY);
		}
		public function get binary():ByteArray
		{
			return this.content as ByteArray;
		}
	}
}
