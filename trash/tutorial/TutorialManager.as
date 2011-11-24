package com.elex.tutorial
{
	import flash.display.DisplayObject;
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;

	public class TutorialManager
	{
		protected static var _groups:Dictionary;
		protected static var _packages:Array=["com.elex.tutorial.steps","com.elex.tutorial.tips"];
		
		public function TutorialManager()
		{
			
		}
		/**
		 * 从一个XML定义来添加一组tutorial，目前不支持group的多级嵌套，没有必要
		 * */
		public static function addXmlDefinition(xml:XML):void
		{
			if(_groups==null) _groups=new Dictionary();
			if(xml.hasOwnProperty("@packages")) parsePackages((xml.@packages).toString());
			var children:XMLList=xml.children();
			var group:TutorialGroup;
			for each(var childXml:XML in children){
				group=TutorialGroup.parseFromXML(childXml);
				_groups[group.id]=group;
			}
		}
		public static function getTutorial(id:String,target:DisplayObject):Tutorial
		{
			var tu:Tutorial;
			for each(var g:TutorialGroup in _groups){
				tu=g.getTutorial(id);
				if(tu) {
					tu.target=target;
					return tu;
				}
			}
			return null;
		}
		public static function getGroup(id:String,target:DisplayObject):TutorialGroup
		{
			var group:TutorialGroup=_groups[id];
			if(group) group.target=target;
			return group;
		}
		public static function get packages():Array
		{
			return _packages;
		}
		public static function getClass(shorClassName:String):Class
		{
			var fullClassName:String;
			for each(var pak:String in _packages){
				fullClassName=pak+"."+shorClassName;
				if(ApplicationDomain.currentDomain.hasDefinition(fullClassName)){
					return ApplicationDomain.currentDomain.getDefinition(fullClassName) as Class;
				}
			}
			return null;
		}
		public  static function get groups():Dictionary
		{
			return _groups;
		}
		private static function parsePackages(value:String):void
		{
			var paks:Array=value.split(",");
			_packages.concat(paks);
		}
	}
}