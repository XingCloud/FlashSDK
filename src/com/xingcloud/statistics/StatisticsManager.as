package com.xingcloud.statistics
{
	import elex.socialize.ElexProxy;
	import elex.socialize.mode.GATrackEventMode;
	import elex.socialize.mode.RequestResponder;
	import elex.socialize.requests.GATrackEventRequest;
	import elex.socialize.requests.XCTrackEventRequest;

	public class StatisticsManager
	{
		private static var _instance:StatisticsManager;

		public static function get instance():StatisticsManager
		{
			if (!_instance)
			{
				_instance=new StatisticsManager(new inlock);
			}
			return _instance;
		}

		public function StatisticsManager(lock:inlock)
		{
		}

		/**
		 *通过Google的统计接口进行统计
		 * @param GtrackMode
		 * @param onSuccess(result:TrackResult)
		 * @param onFail(error:TrackResult)
		 *
		 */
		public function trackEventByGA(trackEvent:GATrackEventMode, onSuccess:Function, onFail:Function):void
		{
			ElexProxy.instance.sendRequest(new GATrackEventRequest(trackEvent, function(result:RequestResponder):void
			{
				var trackResult:TrackResult=new TrackResult();
				trackResult.responder=result;
				if (onSuccess != null)
					onSuccess(trackResult);
			}, function(error:RequestResponder):void
			{
				var trackResult:TrackResult=new TrackResult();
				trackResult.responder=error;
				if (onFail != null)
					onFail(trackResult);
			}));
		}

		/**
		 *通过行云的统计接口进行统计
		 * @param XCtrackMode
		 * @param onSuccess(result:TrackResult)
		 * @param onFail(error:TrackResult)
		 *
		 */
		public function trackEventByXC(trackEvent:XCTrackEvent, onSuccess:Function, onFail:Function):void
		{
			ElexProxy.instance.sendRequest(new XCTrackEventRequest(trackEvent.XCT,
				function(result:RequestResponder):void
			{
				var trackResult:TrackResult=new TrackResult();
				trackResult.responder=result;
				if (onSuccess != null)
					onSuccess(trackResult);
			},
			function(error:RequestResponder):void
			{
				var trackResult:TrackResult=new TrackResult();
				trackResult.responder=error;
				if (onFail != null)
					onFail(trackResult);
			}));
		}
	}
}

internal class inlock
{
}
