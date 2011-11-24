package com.elex.tasks.net {
	import com.elex.tasks.base.Task;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.DataEvent;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	/**
     *加载资源的基类
	 * @author longyangxi
	 */
	
	[Event(name="httpStatus",type="flash.events.HTTPStatusEvent")]
	
	public class AbstractLoader extends Task{
		
		protected var _urlRequest : URLRequest;
		protected var _startTime : int;
		protected var _bandwidth : int = -1;
		
		/**
		 * @param urlOrRequest 文件地址或者UrlRequest
		 */
		public function AbstractLoader(urlOrRequest : *) {	
			super();
			if(urlOrRequest!=null){
				if(urlOrRequest is URLRequest) _urlRequest = urlOrRequest as URLRequest;
				else _urlRequest=new URLRequest(String(urlOrRequest));				
			}
		}
		
		/**
		 * Starts the loading process.
		 * 
		 * @inheritDoc
		 */
		override protected function doExecute():void
		{
			super.doExecute();
			this.addListeners();			
			_startTime = getTimer();
			this.doLoad();
		}
		/**
		 * 放置实际加载执行的动作
		 * */
		protected function doLoad():void
		{
			
		}
		/**
		 * 放置实际取消加载的动作
		 * */
		protected function doCancel():void
		{
			
		}
		/**
		 * 暂停加载
		 */
		override public function set paused(v:Boolean):void
		{
			if(_paused==v) return;
			_paused=v;
			if(!v) {
				this.execute();
				return;
			}
			this.removeListeners();
            this.doCancel();		
		}
		protected function addListeners():void
		{
			// removeLoaderEventListeners(loader);
		}		
		protected function removeListeners() : void 
		{
			// addLoaderEventListeners(loader);
		}

		protected function addLoaderEventListeners( target:IEventDispatcher ) : void {
			target.addEventListener(Event.COMPLETE, onLoadComplete); 
			target.addEventListener(ProgressEvent.PROGRESS, captureProgressEvent);
			target.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			target.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError);   
			target.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus);
		}
		
		protected function removeLoaderEventListeners( target:IEventDispatcher ) : void {
			target.removeEventListener(Event.COMPLETE, onLoadComplete); 
			target.removeEventListener(ProgressEvent.PROGRESS, captureProgressEvent);
			target.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError);   
			target.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus); 
		}
		protected function onLoadComplete(event : Event) : void {
			removeListeners();
			_bandwidth = Math.floor(_total / (getTimer() - _startTime));
			complete();
			trace("AbstractLoadTask->onLoadComplete: ",this.url+" loaded successfully!");
		}
		private function onHttpStatus(event:HTTPStatusEvent):void
		{
			_httpStatus = event.status;
			dispatchEvent( event );
		}
		protected function onLoadError(event : ErrorEvent) : void {
			removeListeners();
			trace("AbstractLoadTask->onLoadError: ",this.url+" loaded error, "+(this._currentRetry+1)+" retry of "+this._retryCount);
			this.notifyError(event.text);
		}
		/**
		 * dispose the <code>AbstractLoader</code>. <code>AbstractLoader</code> internally uses the flash event model 
		 * without weak references so don't forget to finalize the loader, otherwise it will kept in memory.
		 * 
		 * @inheritDoc
		 */
		public function dispose() : void {
			removeListeners();
            this.doCancel();
			_urlRequest = null;
			this.killTimer();
		}
		///////////////////////////////////////////////getter,setter/////////////////////////////////////////////////////
		/**
		 * 加载完成后获取内容，对于图象加载，返回的是BitmapData，SWF加载返回的是MovieClip,其它如XML
		 */
		public function get content() : * {
//			return _loader.content;	
			return null;
		}
		/**
		 * @return the users bandwidth in kilobytes/second
		 * returns -1 if the bandwidth has not been calculated, yet.
		 */
		public function getBandwidth() : int {
			return _bandwidth;
		}
		
		public function get url():String
		{
			if(this._urlRequest) return _urlRequest.url;
			return null;
		}
		/**
		 * The latest HTTP Status code (ex: 404, 500, etc.)
		 */
		protected var _httpStatus:int;
		public function get httpStatus():int {
			return _httpStatus;
		}
	}
}