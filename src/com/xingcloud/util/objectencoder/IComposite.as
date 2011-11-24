package com.xingcloud.util.objectencoder
{
	/**
	 * 
	 * 组合器，用于将不同类型的变量组合成相应的类型
	 * 
	 */	
	public interface IComposite
	{
		/**
		 * 字符串组合
		 * @param s 输入的字符串
		 * @return 组合后的结果
		 * 
		 */		
		function CompositeString(s:String):*;
		/**
		 * 浮点数组合
		 * @param n 输入的浮点数
		 * @return 组合后的结果
		 * 
		 */		
		function CompositeNumber(n:Number):*;
		/**
		 * 布尔型组合 
		 * @param b 输入的布尔值
		 * @return 组合后的结果
		 * 
		 */		
		function CompositeBoolean(b:Boolean):*;
		/**
		 * 整型组合
		 * @param i 输入的整型
		 * @return 组合后的结果
		 * 
		 */		
		function CompositeInt(i:int):*;
		/**
		 * 空类型组合
		 * @return 组合后的结果
		 * 
		 */		
		function CompositeNull():*;
		/**
		 * 数组的组合
		 * @param a 输入的数组
		 * @return 组合后的结果
		 * 
		 */		
		function CompositeArray(a:Array):*;
		/**
		 * 对象的组合
		 * @param o 输入的对象
		 * @return 组合后的结果
		 * 
		 */		
		function CompositeObject(o:Array):*;
	}
}