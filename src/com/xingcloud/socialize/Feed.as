package com.xingcloud.socialize
{
	import elex.socialize.mode.FeedObjectExtend;

	/**
	 * 用于发送feed和message，和模版配合使用。
	 *
	 */
	public class Feed
	{
		/**
		 *新建一个feed对象
		 * @param title_args 用于替换标题中的变量
		 * @param body_args 用于替换主体内容中的变量
		 * @param img_args 用于替换图片地址中的变量
		 * @param title_link_args 用于替换标题链接中的变量
		 * @param img_link_args 用于替换图片链接中的变量
		 * @param uids 使用","分割的一个或多个uid的字符串
		 * @param params 某些平台的自定义feed参数
		 *
		 */
		public function Feed(title_args:Array,
			body_args:Array,
			img_args:Array=null,
			title_link_args:Array=null,
			img_link_args:Array=null,
			uids:String="",
			params:Object=null)
		{
			_foe=new FeedObjectExtend(title_args, body_args, uids, img_args, title_link_args, img_link_args, params);
		}

		private var _foe:FeedObjectExtend;

		internal function get feed():FeedObjectExtend //返回GDP所需对象
		{
			return _foe;
		}
	}
}
