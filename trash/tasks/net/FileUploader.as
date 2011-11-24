package com.elex.tasks.net
{
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.net.FileReference;
	
	import mx.rpc.IResponder;

	[Event(name="open",type="flash.events.Event")]
	public class FileUploader extends AbstractLoader
	{
		protected var _fileReference:FileReference;
		protected var _uploadDataFieldName:String = "FileData";
		protected var _testUpload:Boolean = false;
		
		public function FileUploader(file:FileReference, urlOrRequest:*)
		{
			_fileReference = file;
			super(urlOrRequest);
		}
		override protected function doLoad():void
		{
			_fileReference.upload( _urlRequest, _uploadDataFieldName, _testUpload);	
		}
		override protected function doCancel():void
		{
			try { 
				_fileReference.cancel();
			} catch (e:Error) {
			}	
		}
		override protected function addListeners():void
		{
			if(_fileReference==null) return;
			this.addLoaderEventListeners(_fileReference);
			_fileReference.removeEventListener(Event.COMPLETE, onLoadComplete);
			_fileReference.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, onLoadComplete,false,0,true);
			_fileReference.addEventListener(Event.OPEN, onOpen, false, 0, true  );
		}
		override protected function removeListeners():void
		{
			if(_fileReference==null) return;
			this.removeLoaderEventListeners(_fileReference);
			_fileReference.removeEventListener(Event.OPEN,onOpen);
			_fileReference.removeEventListener(DataEvent.UPLOAD_COMPLETE_DATA, onLoadComplete);
		}
		override public function get  content():*
		{
			_fileReference.data;
		}
		/**
		 * Relay Open events
		 */
		protected function onOpen(event:Event):void
		{
			dispatchEvent( event );
		}
		/////////////////////////////////////getter//////////////////////////////////////////////////
		public function get uploadDataFieldName():String {
			return _uploadDataFieldName;
		}
		public function set uploadDataFieldName(uploadDataFieldName:String):void {
			_uploadDataFieldName = uploadDataFieldName;
		}
		public function get testUpload():Boolean {
			return _testUpload;
		}
		public function set testUpload(testUpload:Boolean):void {
			_testUpload = testUpload;
		}
	}
}