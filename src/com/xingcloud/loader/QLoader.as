package com.xingcloud.loader
{
	import com.xingcloud.core.Config;
	import com.xingcloud.tasks.ParallelTask;
	import flash.utils.Dictionary;

	public class QLoader extends ParallelTask
	{
		private static var _loaders:Dictionary=new Dictionary();

		public static function getLoader(id:String, bandWidth:int=3, retryCount:uint=0):QLoader
		{
			var loader:QLoader=_loaders[id];
			if (!loader)
			{
				loader=new QLoader(id, bandWidth, retryCount);
				_loaders[id]=loader;
			}
			return loader;
		}

		public function QLoader(id:String, bandWidth:int=3, retryCount:uint=0)
		{
			super(bandWidth, 0, 999999, retryCount);
			_queues=new Dictionary();
		}

		private var _queues:Dictionary;

		/**
		 *增加一个加载项
		 * @param url 加载地址
		 * @param type 加载类型
		 * @param cache 是否缓存
		 * @return 承担加载的loader
		 *
		 */
		public function add(url:String, type:String="auto", cache:Boolean=true, param:Object=null):AbstractLoader
		{
			if (type == "auto")
			{
				var file:String=autoMatch(url);
				switch (file)
				{
					case "swf":
					case "jpeg":
					case "png":
					case "jpg":
						type=ResourceType.ASSET_FORMAT;
						break;
					case "xml":
						type=ResourceType.XML_DATA_FORMAT;
						break;
					case "json":
						type=ResourceType.JSON_DATA_FORMAT;
						break;
					case "txt":
					case "html":
						type=ResourceType.TEXT_DATA_FORMAT;
						break;
					default:
						type=ResourceType.BINARY_DATA_FORMAT;
						break;
				}
			}
			var loader:AbstractLoader;
			switch (type)
			{
				case ResourceType.ASSET_FORMAT:
					if (param)
						loader=new AssetsLoader(url, param.context);
					else
						loader=new AssetsLoader(url);
					break;
				case ResourceType.BINARY_DATA_FORMAT:
				case ResourceType.JSON_DATA_FORMAT:
				case ResourceType.TEXT_DATA_FORMAT:
				case ResourceType.XML_DATA_FORMAT:
					loader=new DataLoader(url, type);
					break;
			}
			loader.preventCache=!cache;
			enqueue(loader);
			_queues[url]=loader;
			return loader;
		}

		/**
		 *获取对应url的加载内容，需要此资源已经加载完毕
		 * @param url 资源的url
		 * @return 加载的内容
		 *
		 */
		public function getContent(url:String):Object
		{
			var loader:AbstractLoader=_queues[url];
			if (loader)
				return loader.content;
			else
				return null;
		}

		/**
		 * 启动加载
		 *
		 */
		public function start():void
		{
			execute();
		}


		private function autoMatch(url:String):String
		{
			var type:String=String(url.match(/\.[^.]+$/)[0]).substr(1).toLowerCase();
			return type;
		}
	}
}
