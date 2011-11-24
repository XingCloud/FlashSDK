package  com.xingcloud.net.loader
{
	import com.xingcloud.util.Reflection;
	import com.xingcloud.model.item.ItemsParser;
	import com.xingcloud.model.item.spec.ItemGroup;
	import com.xingcloud.model.item.spec.ItemSpec;
	import com.xingcloud.model.item.spec.ItemSpecManager;

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
		
		public var manager:ItemSpecManager =  ItemSpecManager.instance;
		
		public function DatabaseLoader(path:String):void
		{
			super(path);
		}
		override protected function complete():void
		{
			ItemsParser.parse(this.xml);
			super.complete();
		}	
	}
}
