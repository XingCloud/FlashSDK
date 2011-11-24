package com.xingcloud.statistics
{
	import elex.socialize.mode.XCTrackEventMode;

	public class XCTrackEvent
	{
		public function XCTrackEvent(_method:String, _data:Array, _gameuid:String)
		{
			_xct=new XCTrackEventMode(_method, _data, _gameuid);
		}

		private var _xct:XCTrackEventMode;

		internal function get XCT():XCTrackEventMode
		{
			return _xct;
		}
	}
}
