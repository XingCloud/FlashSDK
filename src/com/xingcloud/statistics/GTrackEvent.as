package com.xingcloud.statistics
{
	import elex.socialize.mode.GTrackEventMode;

	public class GTrackEvent
	{
		public function GTrackEvent(_category:String, _action:String, _optional_label:String, _optional_value:int=0)
		{
			_gt=new GTrackEventMode(_category, _action, _optional_label, _optional_value);
		}

		private var _gt:GTrackEventMode;

		internal function get GT():GTrackEventMode
		{
			return _gt;
		}
	}
}
