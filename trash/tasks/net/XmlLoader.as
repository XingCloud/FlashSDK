package com.elex.tasks.net {
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;

	/**
	 * @author longyangxi
	 */
	public class XmlLoader extends DataLoader {
		public function XmlLoader(urlOrRequest:*) {
			super(urlOrRequest, URLLoaderDataFormat.TEXT);
		}

		/**
		 * @return cast and return the loader content as <code>XML</code> 
		 */
		public function get xml() : XML {
			return new XML(content);
		}
	}
}
