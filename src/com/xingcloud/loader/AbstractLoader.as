package com.xingcloud.loader
{
	import com.xingcloud.core.Config;
	import com.xingcloud.tasks.Task;
	import com.xingcloud.util.Debug;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.utils.getTimer;

	/**
	 *资源加载的基础类。
	 * <p>此类为抽象类，只能够被继承，不能直接进行实例化。用于扩展通过Http获取各种资源的加载器</p>
	 */
	public class AbstractLoader extends Task
	{

		public function AbstractLoader(url:String)
		{
			super();
			_url=url;
		}

		/**
		 *是否阻止缓存重新加载
		 * @default false
		 */
		public var preventCache:Boolean;

		protected var _url:String;
		protected var _content:Object;

		/**
		 *开始加载
		 *
		 */
		public function load():void
		{
			execute();
		}

		/**
		 * 请求地址
		 *
		 */
		public function get url():String
		{
			return _url;
		}

		/**
		 * @private
		 *
		 */
		public function set url(value:String):void
		{
			_url=value;
		}

		public function get content():Object
		{
			return _content;
		}

		override protected function doExecute():void
		{
			_url=validatePath(_url);
			if (preventCache)
			{
				var cacheString:String="ver=" + int(Math.random() * 100 * getTimer());
				if (_url.indexOf("?") == -1)
				{
					_url+="?" + cacheString;
				}
				else
				{
					_url+="&" + cacheString;
				}
			}
			super.doExecute();
			Debug.info("Load resource from {0}", this, _url);
		}

		protected function addLoaderEventListeners(target:IEventDispatcher):void
		{
			target.addEventListener(Event.COMPLETE, onCompleteHandler);
			target.addEventListener(ProgressEvent.PROGRESS, onProgressHandler);
			target.addEventListener(IOErrorEvent.IO_ERROR, onErrorHandler);
			target.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onErrorHandler);
		}

		/**
		 *   @private
		 */
		protected function onCompleteHandler(evt:Event):void
		{
			notifyComplete(this);
			Debug.info("resource {0} load complete", this, _url);
		}

		/**
		 *   @private
		 */
		protected function onErrorHandler(evt:ErrorEvent):void
		{
			notifyError(this);
			Debug.warn("resource {0} load fail", this, _url);
		}


		protected function onProgressHandler(evt:ProgressEvent):void
		{
			this._completeNum=evt.bytesLoaded;
			this._totalNum=evt.bytesTotal;
			notifyProgress(this);
		}

		protected function removeLoaderEventListeners(target:IEventDispatcher):void
		{
			target.removeEventListener(Event.COMPLETE, onCompleteHandler);
			target.removeEventListener(ProgressEvent.PROGRESS, onProgressHandler);
			target.removeEventListener(IOErrorEvent.IO_ERROR, onErrorHandler);
			target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onErrorHandler);
		}

		private function validatePath(path:String):String
		{
			if (path.indexOf("://") == -1) //相对路径，加上webbase
			{
				path=Config.webbase + path;
			}
			return path;
		}
	}
}
