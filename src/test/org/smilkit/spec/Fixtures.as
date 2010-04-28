package org.smilkit.spec
{
	public class Fixtures
	{
		public static var BASIC_SMIL_XML:String = "<?xml version=\"1.0\"?><smil>" +
			"<head><layout><region xml:id=\"root\" width=\"100%\" height=\"100%\" /></layout></head>" +
			"<body><video src=\"http://media.smilkit.org/demo.mp4\" region=\"root\" /></body></smil>";
		
		public static var BASIC_SEQ_SMIL_XML:String = "<?xml version=\"1.0\"?><smil>" +
			"<head><layout><region xml:id=\"root\" width=\"100%\" height=\"100%\" /></layout></head>" +
			"<body><seq id=\"holder\">" +
			"<video id=\"preroll\" src=\"http://media.smilkit.org/preroll.mp4\" dur=\"10s\" />" +
			"<video id=\"content\" src=\"http://media.smilkit.org/demo.mp4\" dur=\"60s\" region=\"root\" />" +
			"</seq></body></smil>";
		
		public static var BASIC_PAR_SMIL_XML:String = "<?xml version=\"1.0\"?><smil>" +
			"<head><layout><region xml:id=\"root\" width=\"100%\" height=\"100%\" /></layout></head>" +
			"<body><par id=\"holder\">" +
			"<video id=\"preroll\" src=\"http://media.smilkit.org/preroll.mp4\" dur=\"10s\" />" +
			"<video id=\"content\" src=\"http://media.smilkit.org/demo.mp4\" dur=\"60s\" region=\"root\" />" +
			"</par></body></smil>";
	}
}