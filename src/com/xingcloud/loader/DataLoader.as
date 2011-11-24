package com.xingcloud.loader
{
	import com.adobe.serialization.json.JSON;
	import com.xingcloud.util.Debug;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;

	/**
	 *加载数据文件，包括text，xml，bytearray
	 * */
	public class DataLoader extends AbstractLoader
	{

		/**
		 *新建一个数据加载器
		 * @param url 加载数据的位置
		 * @param dataFormat 加载的数据格式
		 *
		 */
		public function DataLoader(url:String, dataFormat:String=ResourceType.TEXT_DATA_FORMAT)
		{
			super(url);
			_loader=new URLLoader();
			_dataFormat=dataFormat;
			switch (dataFormat)
			{
				case ResourceType.TEXT_DATA_FORMAT:
				case ResourceType.XML_DATA_FORMAT:
				case ResourceType.JSON_DATA_FORMAT:
					_loader.dataFormat=URLLoaderDataFormat.TEXT;
					break;
				case ResourceType.BINARY_DATA_FORMAT:
					_loader.dataFormat=URLLoaderDataFormat.BINARY;
					break;
			}
			addLoaderEventListeners(_loader);
		}

		protected var _loader:URLLoader;
		protected var _dataFormat:String;

		override protected function clear():void
		{
			removeLoaderEventListeners(_loader);
			super.clear();
		}

		override protected function doExecute():void
		{
			super.doExecute();
			_loader.load(new URLRequest(_url));
		}

		override protected function onCompleteHandler(evt:Event):void
		{
			try
			{
				switch (_dataFormat)
				{
					case ResourceType.TEXT_DATA_FORMAT:
						_content=_loader.data;
						break;
					case ResourceType.XML_DATA_FORMAT:
						_content=new XML(_loader.data);
						break;
					case ResourceType.JSON_DATA_FORMAT:
						_content=JSON.decode(_loader.data);
						break;
					case ResourceType.BINARY_DATA_FORMAT:
						_content=_loader.data;
						break;
				}
			}
			catch (e:Error)
			{
				Debug.error("Can't parse data to the require format.", this);
			}
			super.onCompleteHandler(evt);
		}
	}
}
