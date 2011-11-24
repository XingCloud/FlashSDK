package com.elex.tutorial.tips
{
	import com.elex.tutorial.steps.TutorialStep;
	
	import flash.display.DisplayObject;

    /**
	 * ITutorialTip定义一个图像化的东西，比如高亮，气泡，动画来提示用户当前怎么操作，开发者可以自定义很多的tip
	 * */
	public interface ITutorialTip
	{
		function get owner():TutorialStep;
		function set owner(value:TutorialStep):void;
		/**
		 * 目标对象，比如一个按钮，气泡等tip会根据target来显示
		 * */
		function get target():DisplayObject;
		
		/**
		 * 显示
		 * */
		function show():void;
		/**
		 * 消失
		 * */
		function hide():void;
	}
}