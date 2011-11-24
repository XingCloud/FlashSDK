package com.elex.tutorial.steps
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * 点击某个按钮进入下一步的简单向导 
	 */	

	public class ButtonClickStep extends TutorialStep
	{	
		public function ButtonClickStep()
		{
			super();
		}
		override protected function doExecute():void
		{
			super.doExecute();
			target.addEventListener(MouseEvent.CLICK,onClick);
		}
		private function onClick(e:MouseEvent):void
		{
			target.removeEventListener(MouseEvent.CLICK,onClick);
			this.complete();
		}
	}
}