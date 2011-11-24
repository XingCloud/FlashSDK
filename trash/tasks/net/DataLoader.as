package com.elex.tasks.net{
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.getTimer;
	
	/**
     *加载数据文件的基类，包括xml,text......
	 * 
	 * @author longyangxi
	 */
	public class DataLoader extends AbstractLoader{
		protected var _loader : URLLoader;
		/**
		 * @param urlOrRequest 文件地址或者UrlRequest
		 * @param dataFormat see URLLoaderDataFormat
		 */
		public function DataLoader(urlOrRequest:*, dataFormat : String = "text") {	
			super(urlOrRequest);
			_loader = new URLLoader();
			_loader.dataFormat = dataFormat;
		}

		/**
		 * @inheritDoc
		 */
		override protected function doLoad():void
		{
			_loader.load(_urlRequest);
		}

		/**
		 * @inheritDoc
		 */
		override protected function doCancel():void
		{
			try {
				_loader.close();
			}
			catch(e : Error) {
			}
		}

		override protected function addListeners():void
		{
			if(_loader) {
				this.addLoaderEventListeners(_loader);
			}			
		}
        override protected function  removeListeners():void
		{
			if(_loader) {
				this.removeLoaderEventListeners(_loader);
			}
		}
		override public function dispose() : void {
			super.dispose();
			_loader = null;
		}

		/**
		 * Provides access to the the loaded data
		 * 
		 * @return the loaded data
		 * @throws Error if content has not been loaded successfully
		 */
		override public function get content() : * {
			try {
				return _loader.data;
			}
			catch(e : Error) {
				throw new Error(this + " Content has not been loaded successfully. " + e.message);
			}
		}
	}
}
