package com.elex.tutorial.tips
{
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * 高亮显示某个显示对象，这个对象范围以外的东西都被半透明覆盖，在向导系统里经常要用
	 * */
	public class Highlight extends AbstractTip
	{
		/**
		 *hilight 的颜色 
		 */		
		public var strokeColor:uint = 0x00ff00;
		/**
		 *hilight 的线条笔画粗细 
		 */		
		public var strokeWeight:Number = 2;
		
		public function Highlight()
		{
			
		}
		override protected function doShow():void
		{
			super.doShow();
			var p:Point=new Point();
			if(_rect==null) {
				if(target) {
					_rect=target.getBounds(target);
					p=target.localToGlobal(new Point(_rect.x,_rect.y));
				}else {
					return;
				}
			}else{
				p.x=_rect.x;
				p.y=_rect.y;
			}
			//下面这个方法可以画出一个矩形填充，中间挖空一个矩形
			_canvas.graphics.beginFill(0x0,0.5);
			_canvas.graphics.drawRect(0,0,target.stage.stageWidth,target.stage.stageHeight);
			_canvas.graphics.lineStyle(strokeWeight,strokeColor);
			_canvas.graphics.drawRect(p.x,p.y,_rect.width,_rect.height);
			_canvas.graphics.endFill();
		}
	}
}