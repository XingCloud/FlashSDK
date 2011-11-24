package com.elex.tasks.net
{
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.Dictionary;
	import flash.utils.describeType;

	public class GameconstLoader extends XmlLoader
	{
		/**
		 *这个值是具体要将平衡性数据放置到那个平衡类中去。类名 
		 */		
		public var constClass:Class;
		/**
		 * @spreedsheetUrl google spreadSheet的url："http://spreadsheets.google.com/feeds/cells/0AhE91z3arqEDdHdQaF8tbmZGcGx5dXRob0RleXNVcVE/od6/public/basic"
		 *                 产生方法如下:
		 * 		           1、建立一个google的Excle文档。
		 *                 2、选择共享-》发布为网页
		 *                 3、点击“获取已发布数据的链接”下的下拉框，选择ATOM。选中单元格。
		 *                 然后将下面的链接复制过来，赋给spreadSheedurl。
		 * @proxyUrl 这里的值是你的php代理的url,如："http://yoururl.com/GET_GoogleSpreadsheetProxy.php"
		 * */
		public function GameconstLoader(spreadsheetUrl:String,proxyUrl:String,constClass:Class)
		{
			var ur:URLRequest = new URLRequest(proxyUrl);
			ur.method = URLRequestMethod.POST;
			ur.data = new URLVariables();
			ur.data["url"] = spreadsheetUrl;
			this.constClass=constClass;
			super(ur);
		}
		override protected function complete():void
		{
			parseSpreadsheet(this.xml);
			super.complete();
		}
		private function parseSpreadsheet(xmlData:XML):void
		{
			// Extract the entries.
			var xmlns:Namespace = new Namespace("xmlns", "http://www.w3.org/2005/Atom");
			xmlData.addNamespace(xmlns);
			
			// Parse into a dictionary.
			var cellDictionary:Dictionary = new Dictionary();
			var res:XMLList = xmlData.xmlns::entry;
			for each(var entryXML:XML in res)
			{
				//Logger.print(this, "Cell " + entryXML.xmlns::title.toString() + " = " + entryXML.xmlns::content.toString());
				cellDictionary[entryXML.xmlns::title.toString()] = entryXML.xmlns::content.toString();
			}
			var constDis:XML=describeType(constClass);
			var constVariable:XMLList=constDis.variable;
			
			for each(var xml:XML in constVariable)
			{
				if((xml.metadata.arg.(@key=="Cell"))=="")
				{
					constClass[xml.@name]=cellDictionary[xml.metadata.arg.(@key=="Cell").@value];
				}
			}
		}
	}
}