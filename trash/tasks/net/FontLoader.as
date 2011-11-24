package com.elex.tasks.net
{
	import com.elex.core.Reflection;
	
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	import flash.text.Font;
	
	public class FontLoader extends AssetsLoader
	{
		public function FontLoader(urlOrRequest:*, domain:ApplicationDomain=null)
		{
			super(urlOrRequest, domain);
		}
		override protected function onLoadComplete(event:Event):void
		{
			if(this._domain==null) this._domain=_loader.contentLoaderInfo.applicationDomain;
			//获取字体文件里所有可能的字体元件定义，并注册之
			var fontNames:Array=Reflection.getDefinitionNames(_loader.contentLoaderInfo,false,true);
			for each(var fontName:String in fontNames){
				var fontClass:Class=_domain.getDefinition(fontName) as Class;
				if(fontClass==null) continue;
				try{
					Font.registerFont(fontClass);
					trace("Register font: "+fontName);
				}catch(e:Error){
					trace("Register font error!");
				}
			}
			super.onLoadComplete(event);
		}
	}
}