package com.xingcloud.net.loader
{
	import com.xingcloud.util.Reflection;
	
	import flash.events.Event;
		import flash.system.ApplicationDomain;
	import flash.text.Font;
	
	public class FontLoader extends AssetsLoader
	{
		public function FontLoader(urlOrRequest:*)
		{
			super(urlOrRequest);
		}
		override protected function onLoadComplete(event:Event):void
		{
			if(this._domain==null) this._domain=_loader.contentLoaderInfo.applicationDomain;
			//获取字体文件里所有可能的字体元件定义，并注册之
			var fontNames:Array=Reflection.getDefinitionNames(_loader.contentLoaderInfo,false,true);
			for each(var fontName:String in fontNames){
				if(!_domain.hasDefinition(fontName)) continue;
				registerFont(fontName);
			}
			super.onLoadComplete(event);
		}
		private function registerFont(fontName:String):void
		{
			var fontClass:Class=_domain.getDefinition(fontName) as Class;
			try{
				Font.registerFont(fontClass);
				trace("Register font: "+(new fontClass() as Font).fontName,"class: "+fontName);
			}catch(e:Error){
				//nothing
			}
		}
	}
}