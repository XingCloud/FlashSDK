package  com.elex.tasks.net
{
	import com.elex.core.ELEX;
	import com.elex.core.Reflection;
	import com.elex.items.spec.DatabaseParser;
	import com.elex.items.spec.ItemGroup;
	import com.elex.items.spec.ItemSpec;
	import com.elex.items.spec.ItemsManager;

	/**
	 * 建立ItemSpec的map
	 * xml文件中对于item的描述应与相应的ItemSpec类保持一致,如作物对应的itemSpec为CropItemSpec,XML文件中的描述用crop. 
	 * @author Administrator
	 * 
	 */
	public class DatabaseLoader extends XmlLoader
	{
		private var default_item_class:Class = ItemSpec;
		private var default_group_class:Class=ItemGroup;
		
		public var pArray:Array = new Array();
		
//		public var encrypt:Boolean;
		
		public var manager:ItemsManager =  ItemsManager.instance;
		
		public function DatabaseLoader(path:String):void
		{
			super(path);
		}
		override protected function complete():void
		{
			DatabaseParser.parse(this.xml);
			super.complete();
		}	
	}
}