package com.xingcloud.net.loader
{
	import flash.events.Event;
		import flash.text.StyleSheet;
	
	public class CSSLoader extends DataLoader
	{
		public function CSSLoader(urlOrRequest:*)
		{
			super(urlOrRequest);
				this._styleSheet=new StyleSheet();
		}
			protected var _styleSheet:StyleSheet;
			override protected function onLoadComplete(event:Event):void
			{
				this._styleSheet.parseCSS(this._loader.data);
				super.onLoadComplete(event);
			}
			public function get styleSheet():StyleSheet
			{
				return _styleSheet;
			}
	}
}