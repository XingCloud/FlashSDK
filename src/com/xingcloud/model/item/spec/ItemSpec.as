package com.xingcloud.model.item.spec
{
	

   /**
   * 单个物品定义的基类
   * */
	public class ItemSpec extends ItemBase
	{
		public function ItemSpec()
		{
			super();
		}
		/**
		 *是否在某个物品定义组内 
		 * @param _group
		 * @return 
		 * 
		 */		
		public function inGroup(_group:String):Boolean
		{
			var par:ItemGroup=this.parent;
			while(par){
				if(par.name==_group) return true;
				par=par.parent;
			}
			return false;
		}
	}
}