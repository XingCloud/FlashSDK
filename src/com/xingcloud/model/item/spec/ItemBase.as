package com.xingcloud.model.item.spec
{
	/**
	 * itemSpec和itemGroup的共同基类
	 * */
	public class ItemBase
	{
		/**唯一标志，必须**/
		public var id:String;
		/**名字，不同语种可能不一样**/
		public var name:String;
		/**描述，不同语种可能会不一样**/
		public var description:String;
		/**父亲**/
		public var parent:ItemGroup;
		/**XML源定义**/
		public var xml:XML;
	}
}