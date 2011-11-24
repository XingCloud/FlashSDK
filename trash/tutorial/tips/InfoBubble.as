package com.elex.tutorial.tips
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.text.*;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	/**
	 * 常见的信息泡，提示用户操作
	 * */
	public class InfoBubble extends AbstractTip
	{
		/**
		 * 信息泡的标题
		 * */
		public var title:String;
		/**
		 * 信息泡的描述信息
		 * */
		public var message:String;
        //信息框的位置微调,offsetX>0表示往右调，offsetY>0表示往下调
        public var offsetX:int=0
        public var offsetY:int=-10
			
//		public var showTime:int=-1;
		//objects
		protected var _tf:TextField;  // title field
		protected var _cf:TextField;  //content field
		protected var _icon:DisplayObject
		
		//formats
		protected var _titleFormat:TextFormat;
		protected var _contentFormat:TextFormat;
		
		/* check for format override */
		protected var _titleOverride:Boolean = false;
		protected var _contentOverride:Boolean = false;
		
		//defaults
		protected var _defaultWidth:Number = 200;
		//文字与边框的间距
		protected var _buffer:Number =6;
		protected var _align:String = "center"
		protected var _cornerRadius:Number = 12;
		protected var _bgColors:Array = [0xFFFFFF, 0x9C9C9C];
		protected var _autoSize:Boolean = true;
		protected var _hookEnabled:Boolean = true;
		protected var _hookSize:Number = 10;
		
		//offsets
		protected var _offSet:Number;
		protected var _hookOffSet:Number;
		
        //上一次显示消失完毕才能再显示
        protected var canShow:Boolean=true
	
		public function InfoBubble():void {
			//do not disturb parent display object mouse events
			//初始化文字格式
			this.initTextFormat()
		}		
		override protected function doShow():void
		{
			super.doShow();
			if(!this.canShow) return;
			if(this.title==null)   this.title=_owner.name;
			if(this.message==null) this.message=_owner.description;
			
			this.addCopy( title, message );
			this.setOffset();
			this.drawBG();
			this.bgGlow();
			
			//initialize coordinates
			_canvas.mouseChildren=false;
			_canvas.mouseEnabled=false;
            setPosition();
			this.enableTick( true );
		}
		protected function setPosition():void {
			var pn:Point;
			if(_explicitTarget) pn=this.targetCenterTop;
			else pn=new Point((_rect.left+_rect.right)/2,_rect.y);
			
			var xp:Number =pn.x + this._offSet+this.offsetX;
			var yp:Number =pn.y - _canvas.height+this.offsetY;
			
			var overhangRight:Number = this._defaultWidth + xp;
			if( overhangRight > target.stage.stageWidth ){
				xp =  target.stage.stageWidth -  this._defaultWidth;
			}
			if( xp < 0 ) {
				xp = 0;
			}
			if( yp < 0 ){
				yp = 0;
			}
			_canvas.x=xp;
			_canvas.y=yp;
		}
		override protected function doHide():void {
			super.doHide();
			this.canShow=true
			this.cleanUp();
		}
		protected function initTextFormat():void
		{
			//标题格式
			_titleFormat = new TextFormat();
			_titleFormat.font = "_sans";
			_titleFormat.bold = true;
			_titleFormat.size = 14;
			_titleFormat.color = 0x333333;
			//内容格式
			_contentFormat = new TextFormat();
			_contentFormat.font = "_sans";
			_contentFormat.bold = false;
			_contentFormat.size = 12;
			_contentFormat.color = 0x333333;
		}
		protected function enableTick( value:Boolean ):void {
			if( value ){
				_canvas.addEventListener( Event.ENTER_FRAME, this.tick );
			}else{
				_canvas.removeEventListener( Event.ENTER_FRAME, this.tick );
			}
		}
		protected function tick( event:Event ):void {
//			if((this.showTime>0)&&((getTimer()-this.startTime)>this.showTime*1000)){
//				this.hide();
//			}
		}
		
		protected function addCopy( title:String, content:String ):void {
			var titleIsDevice:Boolean = this.isDeviceFont(  _titleFormat );
			//添加标题
			this._tf = this.createField( titleIsDevice ); 
			this._tf.htmlText = title;
			this._tf.setTextFormat( this._titleFormat, 0, title.length );
			if( this._autoSize ){
				this._defaultWidth = this._tf.textWidth + 4 + ( _buffer * 2 );
			}else{
				this._tf.width = this._defaultWidth - ( _buffer * 2 );
			}
			
			this._tf.x = this._tf.y = this._buffer;
			this.textGlow( this._tf );
			_canvas.addChild( this._tf );
			//添加图示
			if(this._icon!=null){
				var rect:Rectangle=_icon.getBounds(_icon);
				this._icon.x=this._buffer+this._icon.width/2-(rect.left+rect.right)/2;
				this._icon.y=this.bounds.height+5+this._icon.height/2-(rect.top+rect.bottom)/2;
				_canvas.addChild(this._icon)
			}
			//添加内容
			if( content != null ){
				//check for device font
				var contentIsDevice:Boolean = this.isDeviceFont(  _contentFormat );
				this._cf = this.createField( contentIsDevice );
				this._cf.htmlText = content;

				this._cf.x = this._buffer;
				this._cf.y = this.bounds.height + 5;
				this.textGlow( this._cf );
				this._cf.setTextFormat( this._contentFormat );
				if( this._autoSize ){
					var cfWidth:Number = this._cf.textWidth + 4 + ( _buffer * 2 )
					this._defaultWidth = cfWidth > this._defaultWidth ? cfWidth : this._defaultWidth;
				}else{
					this._cf.width = this._defaultWidth - ( _buffer * 2 );
				}
				_canvas.addChild( this._cf );	
			}
		}
		//对象的顶部中间点作为信息框的显示基点
		protected function get targetCenterTop():Point
		{
			if(target){
				var rect:Rectangle=target.getBounds(_canvas);
				return new Point((rect.left+rect.right)/2,rect.top);				
			}
			return null;
		}
		//create field, if not device font, set embed to true
		protected function createField( deviceFont:Boolean ):TextField {
			var tf:TextField = new TextField();
			tf.embedFonts = ! deviceFont;
			tf.gridFitType = "pixel";
			//tf.border = true;
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.selectable = false;
			if( ! this._autoSize ){
				tf.multiline = true;
				tf.wordWrap = true;
			}
			return tf;
		}
		protected function get bounds():Rectangle
		{
			return _canvas.getBounds( _canvas )
		}
		
		//draw background, use drawing api if we need a hook
		protected function drawBG():void {
			var fillType:String = GradientType.LINEAR;
		   	//var colors:Array = [0xFFFFFF, 0x9C9C9C];
		   	var alphas:Array = [1, 1];
		   	var ratios:Array = [0x00, 0xFF];
		   	var matr:Matrix = new Matrix();
			var radians:Number = 90 * Math.PI / 180;
		  	matr.createGradientBox(this._defaultWidth, this.bounds.height + ( this._buffer * 2 ), radians, 0, 0);
		  	var spreadMethod:String = SpreadMethod.PAD;
			_canvas.graphics.beginGradientFill(fillType, this._bgColors, alphas, ratios, matr, spreadMethod); 
			if( this._hookEnabled ){
				var xp:Number = 0; var yp:Number = 0; var w:Number = this._defaultWidth; var h:Number = this.bounds.height + ( this._buffer * 2 );
				_canvas.graphics.moveTo ( xp + this._cornerRadius, yp );
				_canvas.graphics.lineTo ( xp + w - this._cornerRadius, yp );
				_canvas.graphics.curveTo ( xp + w, yp, xp + w, yp + this._cornerRadius );
				_canvas.graphics.lineTo ( xp + w, yp + h - this._cornerRadius );
				_canvas.graphics.curveTo ( xp + w, yp + h, xp + w - this._cornerRadius, yp + h );
				
				//hook
				_canvas.graphics.lineTo ( xp + this._hookOffSet + this._hookSize, yp + h );
				_canvas.graphics.lineTo ( xp + this._hookOffSet , yp + h + this._hookSize );
				_canvas.graphics.lineTo ( xp + this._hookOffSet - this._hookSize, yp + h );
				_canvas.graphics.lineTo ( xp + this._cornerRadius, yp + h );
				
				_canvas.graphics.curveTo ( xp, yp + h, xp, yp + h - this._cornerRadius );
				_canvas.graphics.lineTo ( xp, yp + this._cornerRadius );
				_canvas.graphics.curveTo ( xp, yp, xp + this._cornerRadius, yp );
				_canvas.graphics.endFill();
			}else{
				_canvas.graphics.drawRoundRect( 0, 0, this._defaultWidth, this.bounds.height + ( this._buffer * 2 ), this._cornerRadius );
			}
		}

		
		
		
		/* Fade In / Out */
		
//		protected function animate( show:Boolean ):void {
//			var end:int = show == true ? 1 : 0;
//			_tween=new GTween(this,.5,{alpha:end});
//			if( ! show ){
//				_tween.onComplete=onComplete
//				_timer.reset();
//			}
//		}
	
		/* End Fade */
		
		/** Getters / Setters */
		
		public function set width( value:Number ):void {
			this._defaultWidth = value;
		}
		
		public function set titleFormat( tf:TextFormat ):void {
			this._titleFormat = tf;
			if( this._titleFormat.font == null ){
				this._titleFormat.font = "_sans";
			}
			this._titleOverride = true;
		}
		public function get titleFormat():TextFormat
		{
			return this._titleFormat
		}
		public function set contentFormat( tf:TextFormat ):void {
			this._contentFormat = tf;
			if( this._contentFormat.font == null ){
				this._contentFormat.font = "_sans";
			}
			this._contentOverride = true;
		}
		public function get contentFormat():TextFormat
		{
			return this._contentFormat
		}		
		[Inspectable(enumeration="left,right,center")]
		public function set align( value:String ):void {
			var a:String = value.toLowerCase();
			var values:String = "right left center";
			if( values.indexOf( value ) == -1 ){
				throw new Error( this + " : Invalid Align Property, options are: 'right', 'left' & 'center'" );
			}else{
				this._align = a;
			}
		}
		public function set hook( value:Boolean ):void {
			this._hookEnabled = value;
		}
		public function set hookSize( value:Number ):void {
			this._hookSize = value;
		}
		public function set cornerRadius( value:Number ):void {
			this._cornerRadius = value;
		}
		public function set colors( colArray:Array ):void {
			this._bgColors = colArray;
		}
		public function set autoSize( value:Boolean ):void {
			this._autoSize = value;
		}
		/* End Getters / Setters */
		/* Cosmetic */
		
		protected function textGlow( field:TextField ):void {
			var color:Number = 0x000000;
            var alpha:Number = 0.35;
            var blurX:Number = 2;
            var blurY:Number = 2;
            var strength:Number = 1;
            var inner:Boolean = false;
            var knockout:Boolean = false;
            var quality:Number = BitmapFilterQuality.HIGH;

           var filter:GlowFilter = new GlowFilter(color,
                                  alpha,
                                  blurX,
                                  blurY,
                                  strength,
                                  quality,
                                  inner,
                                  knockout);
            var myFilters:Array = new Array();
            myFilters.push(filter);
        	field.filters = myFilters;
		}
		
		protected function bgGlow():void {
			var color:Number = 0x000000;
            var alpha:Number = 0.20;
            var blurX:Number = 5;
            var blurY:Number = 5;
            var strength:Number = 1;
            var inner:Boolean = false;
            var knockout:Boolean = false;
            var quality:Number = BitmapFilterQuality.HIGH;

           var filter:GlowFilter = new GlowFilter(color,
                                  alpha,
                                  blurX,
                                  blurY,
                                  strength,
                                  quality,
                                  inner,
                                  knockout);
            var myFilters:Array = new Array();
            myFilters.push(filter);
			_canvas.filters = myFilters;
		}
	
		/* End Cosmetic */
	
	
		
		/* Helpers */
		
		/* Check if font is a device font */
		protected function isDeviceFont( format:TextFormat ):Boolean {
			var font:String = format.font;
			var device:String = "_sans _serif _typewriter";
			return device.indexOf( font ) > -1;
			//_sans
			//_serif
			//_typewriter
		}
		
		protected function setOffset():void {
			switch( this._align ){
				case "left":
					this._offSet = - _defaultWidth +  ( _buffer * 3 ) + this._hookSize; 
					this._hookOffSet = this._defaultWidth - ( _buffer * 3 ) - this._hookSize; 
				break;
				
				case "right":
					this._offSet = 0 - ( _buffer * 3 ) - this._hookSize;
					this._hookOffSet =  _buffer * 3 + this._hookSize;
				break;
				
				case "center":
					this._offSet = - ( _defaultWidth / 2 );
					this._hookOffSet =  ( _defaultWidth / 2 );
				break;
				
				default:
					this._offSet = - ( _defaultWidth / 2 );
					this._hookOffSet =  ( _defaultWidth / 2 );;
				break;
			}
		}
		
		/* End Helpers */
		
		
		
		/* Clean */
		
		protected function cleanUp():void {
			this.enableTick( false );
			_canvas.filters = [];
            this.cleanTxt()
			_canvas.graphics.clear();
			if(this._icon!=null){
				_canvas.removeChild(this._icon)
				this._icon=null
			}
		}
		protected function cleanTxt():void
		{
			if(this._tf!=null){
				this._tf.filters = [];
				_canvas.removeChild( this._tf );
				this._tf = null;				
			}
			if( this._cf != null ){
				this._cf.filters = []
				_canvas.removeChild( this._cf );
				this._cf=null
			}			
		}
		
		/* End Clean */
		
		
	}
}
