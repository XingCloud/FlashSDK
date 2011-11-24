package com.xingcloud.util
{
	import com.xingcloud.core.XingCloud;
	import com.xingcloud.model.ModelBase;
	import com.xingcloud.util.objectencoder.ObjectEncoder;
	
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.StatusEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.LocalConnection;
	import flash.system.System;
	import flash.ui.KeyLocation;
	import flash.ui.Keyboard;
	import flash.utils.Timer;

	public class Debug
	{
		public static const CONSOLE_OUTPUT:String="console_output";
		public static const BUILDERIN_OUTPUT:String="builderin_output";
		public static const TRACE_OUTPUT:String="trace_output";
		
		/**
		 * 开关日志打印
		 * @default true
		 */
		public static var allowLog:Boolean=true;
		/**
		 *是否打印错误
		 * @default true
		 */
		public static var showError:Boolean=true;
		/**
		 *是否打印警告
		 * @default true
		 */
		public static var showWarning:Boolean=true;
		/**
		 *是否打印一般日志
		 * @default true
		 */
		public static var showInfo:Boolean=true;
		/**
		 *保存显示则最大日志数，用于Debug.MEM_OUTPUT输出
		 * @default 300
		 */
		public static var MaxLogNum:int=300;
		private static var _logOutput:String=Debug.TRACE_OUTPUT;

		private static var logInMem:Array=[];
		private static var RED:String="#CC0000";
		private static var GREEN:String="#00CC00";
		private static var BLUE:String="#6666CC";
		private static var PINK:String="#CC00CC";
		private static var YELLOW:String="#CCCC00";

		private static var logPanel:panel;
		private static var panelShow:Boolean=false;

		/**
		 *打印日志
		 * @param message 日志消息，可包含{0},{1}...，依次被rests里的参数所替换
		 * @param target 输出日志的对象
		 * @param rests 用于替换的参数
		 *
		 */
		public static function info(message:String, target:Object=null, ... rests):void
		{
			if (allowLog && showInfo)
				send("INFO:" + generateMessage(message, target, rests), GREEN,"info");
		}

		/**
		 *打印错误
		 * @param message 错误消息，可包含{0},{1}...，依次被rests里的参数所替换
		 * @param target 输出错误的对象
		 * @param rests 用于替换的参数
		 *
		 */
		public static function error(message:String, target:Object=null, ... rests):void
		{
			if (allowLog && showError)
				send("ERROR:" + generateMessage(message, target, rests), RED,"error");
		}

		/**
		 *打印警告
		 * @param message 警告消息，可包含{0},{1}...，依次被rests里的参数所替换
		 * @param target 输出警告的对象
		 * @param rests 用于替换的参数
		 *
		 */
		public static function warn(message:String, target:Object=null, ... rests):void
		{
			if (allowLog && showWarning)
				return send("WARNING:" + generateMessage(message, target, rests), YELLOW,"warn");
		}

		/**
		 * 清除日志，用于Debug.MEM_OUTPUT类型
		 *
		 */
		public static function clear():void
		{
			logInMem=[];
			logPanel.txt.htmlText="";
		}

		/**
		 *
		 * 打印内存使用情况
		 *
		 */
		public static function memory():void
		{
			send("TotalMemory useage:" + System.totalMemory, BLUE);
		}
		public static function frameRate():void
		{
			if(XingCloud.stage)
				send("Current frame rate:" + XingCloud.stage.frameRate, BLUE);
		}

		/**
		 *日志打印的方式
		 * @default Debug.TRACE_OUTPUT
		 */
		public static function get output():String
		{
			return _logOutput;
		}

		/**
		 * @private
		 */
		public static function set output(value:String):void
		{
			_logOutput=value;
			if(XingCloud.stage)
			{
				changeListenState();
			}
			else
			{
				var timer:Timer=new Timer(500);
				timer.addEventListener(TimerEvent.TIMER,onCheckStage);
				timer.start();
			}
		}
		
		private static function onCheckStage(event:TimerEvent):void
		{
			if(XingCloud.stage)
			{
				changeListenState();
				event.target.stop();
				event.target.removeEventListener(TimerEvent.TIMER,onCheckStage);
			}
		}
		private static function changeListenState():void
		{
			if (_logOutput ==BUILDERIN_OUTPUT)
				XingCloud.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUP);
			else
				XingCloud.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUP);
		}
		
		private static function send(value:String, color:String,consoleLevel:String="info"):void
		{
			if (_logOutput  == TRACE_OUTPUT)
			{
				trace(value);
			}
			else if(_logOutput ==CONSOLE_OUTPUT)
			{
				if (ExternalInterface.available)
				{
					try
					{
						ExternalInterface.call("function(text){if (window.console) window.console."+consoleLevel+"(text);}", value);
					}
					catch (e:Error)
					{
						
					}
				}
			}
			else
			{
				if (logInMem.length <= MaxLogNum)
				{
					logInMem.push("<font color=\""+color+"\">"+value+"</font>");
				}
				else
				{
					logInMem.shift();
					logInMem.push("<font color=\""+color+"\">"+value+"</font>");
				}
				if (logPanel && panelShow)
					logPanel.txt.appendText("\n\n" + value);
			}
		}

		private static function timestamp():String
		{
			return "[" + new Date().toString() + "]";
		}

		private static function targetName(target:Object):String
		{
			if (target)
				return "[" + Reflection.tinyClassName(target) + "]";
			else
				return "";
		}

		private static function generateMessage(msg:String, target:Object, rest:Array):String
		{
			for (var i:int=0; i < rest.length; i++)
			{
				var paramString:String;
				if (Reflection.isSimple(rest[i]))
				{
					paramString=rest[i].toString();
				}
				else
				{
					paramString=new ObjectEncoder(rest[i], ObjectEncoder.JSON, false, [ModelBase]).JsonString;
				}
				msg=msg.replace(new RegExp("\\{" + i + "\\}", "g"), paramString);
			}
			return timestamp() + targetName(target) + msg;
		}

		private static function onKeyUP(event:KeyboardEvent):void
		{
			if (event.ctrlKey && event.altKey)
			{
				if (event.keyCode == 80)
				{
					if (panelShow && XingCloud.stage.contains(logPanel))
					{
						XingCloud.stage.removeChild(logPanel);
						panelShow=false;
					}
					else if (!panelShow)
					{
						panelShow=true;
						if (!logPanel)
						{
							logPanel=new panel();
						}
						logPanel.txt.htmlText=logInMem.join("\n\n");
						XingCloud.stage.addChild(logPanel);
					}
				}
				else if (event.keyCode == 67)
				{
					clear();
				}

			}
		}
	}
}

import com.xingcloud.core.XingCloud;

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;

internal class panel extends Sprite
{
	public function panel()
	{
		var w:int=XingCloud.stage.stageWidth;
		var h:int=XingCloud.stage.stageHeight;
		txt=new TextField();
		txt.width=w;
		txt.height=h;
		txt.multiline=true;
		txt.wordWrap=true;
		txt.defaultTextFormat=new TextFormat(null,15,0xffffff);
		addChild(txt);
		graphics.beginFill(0, 0.8);
		graphics.drawRect(0, 0, w, h);
		graphics.endFill();
	}

	public var txt:TextField;
}

