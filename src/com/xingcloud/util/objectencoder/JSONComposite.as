package com.xingcloud.util.objectencoder
{

	public class JSONComposite implements IComposite
	{
		/**
		 *创建一个json组装器
		 * @param encoder 应用的解析器
		 *
		 */
		public function JSONComposite(encoder:ObjectEncoder)
		{
			_encoder=encoder;
		}

		private var _encoder:ObjectEncoder;

		public function CompositeArray(a:Array):*
		{
			var s:String="";
			for each (var item:* in a)
			{
				s+=(_encoder.convertTo(item) + ",");
			}
			s=s.substring(0, s.length - 1);
			return "[" + s + "]";
		}

		public function CompositeBoolean(b:Boolean):*
		{
			return b ? "true" : "false";
		}

		public function CompositeInt(i:int):*
		{
			return isFinite(i as Number) ? i.toString() : "0";
		}

		public function CompositeNull():*
		{
			return "\"\"";
		}

		public function CompositeNumber(n:Number):*
		{
			return isFinite(n as Number) ? n.toString() : "NaN";
		}

		public function CompositeObject(o:Array):*
		{
			var s:String="";
			for each (var item:Object in o)
			{
				s+=(escapeString(item.key) + ":" + _encoder.convertTo(item.value) + ",");
			}
			s=s.substring(0, s.length - 1);
			if(s)
				return "{" + s + "}";
			else
				return "\"\"";
		}

		public function CompositeString(s:String):*
		{
			return escapeString(s);
		}

		private function escapeString(str:String):String
		{
			// create a string to store the string's jsonstring value
			var s:String="";
			// current character in the string we're processing
			var ch:String;
			// store the length in a local variable to reduce lookups
			var len:Number=str.length;

			// loop over all of the characters in the string
			for (var i:int=0; i < len; i++)
			{
				// examine the character to determine if we have to escape it
				ch=str.charAt(i);
				switch (ch)
				{
					case '"': // quotation mark
						s+="\\\"";
						break;

					//case '/':	// solidus
					//	s += "\\/";
					//	break;

					case '\\': // reverse solidus
						s+="\\\\";
						break;

					case '\b': // bell
						s+="\\b";
						break;

					case '\f': // form feed
						s+="\\f";
						break;

					case '\n': // newline
						s+="\\n";
						break;

					case '\r': // carriage return
						s+="\\r";
						break;

					case '\t': // horizontal tab
						s+="\\t";
						break;

					default: // everything else

						// check for a control character and escape as unicode
						if (ch < ' ')
						{
							// get the hex digit(s) of the character (either 1 or 2 digits)
							var hexCode:String=ch.charCodeAt(0).toString(16);

							// ensure that there are 4 digits by adjusting
							// the # of zeros accordingly.
							var zeroPad:String=hexCode.length == 2 ? "00" : "000";

							// create the unicode escape sequence with 4 hex digits
							s+="\\u" + zeroPad + hexCode;
						}
						else
						{

							// no need to do any special encoding, just pass-through
							s+=ch;

						}
				} // end switch

			} // end for loop

			return "\"" + s + "\"";
		}
	}
}
