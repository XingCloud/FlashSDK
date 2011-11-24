package com.xingcloud.net.loader
{
	import com.xingcloud.core.Config;
	import com.xingcloud.core.xingcloud_internal;

	use namespace xingcloud_internal;
	public class ConfigLoader extends XmlLoader
	{
		public function ConfigLoader(urlOrRequest:*)
		{
			super(urlOrRequest);
		}
		override protected function complete():void
		{
			Config.parseFromXML(this.xml);
			super.complete();
		}
	}
}