package org.smilkit.spec
{
	public class Fixtures
	{
		public static var BASIC_SMIL_XML:String = "<?xml version=\"1.0\"?><smil>" +
			"<head><layout><region xml:id=\"root\" width=\"100%\" height=\"100%\" /></layout></head>" +
			"<body><video src=\"http://cloud.sixones.com/family-guy-trailer.mp4\" region=\"root\" /></body></smil>";
		
		public static var BASIC_SEQ_SMIL_XML:String = "<?xml version=\"1.0\"?><smil>" +
			"<head><layout><region xml:id=\"root\" width=\"100%\" height=\"100%\" /></layout></head>" +
			"<body><seq id=\"holder\">" +
			"<video id=\"preroll\" src=\"http://cloud.sixones.com/family-guy-trailer.mp4\" dur=\"10s\" />" +
			"<video id=\"content\" src=\"http://media.smilkit.org/demo.mp4\" dur=\"60s\" region=\"root\" />" +
			"</seq></body></smil>";
		
		public static var BASIC_PAR_SMIL_XML:String = "<?xml version=\"1.0\"?><smil>" +
			"<head><layout><region xml:id=\"root\" width=\"100%\" height=\"100%\" /></layout></head>" +
			"<body><par id=\"holder\">" +
			"<video id=\"preroll\" src=\"http://cloud.sixones.com/family-guy-trailer.mp4\" dur=\"10s\" />" +
			"<video id=\"content\" src=\"http://media.smilkit.org/demo.mp4\" dur=\"60s\" region=\"root\" />" +
			"</par></body></smil>";
		
		public static var MP4_VIDEO_SMIL_XML:String =  "<?xml version=\"1.0\"?><smil>" +
			"<head><layout><region xml:id=\"root\" width=\"100%\" height=\"100%\" /></layout></head>" +
			"<body><seq id=\"holder\">" +
			"<video id=\"video_http\" src=\"http://assets.videojuicer.net/smilkit/bcf93ccc-7e18-11df-a68c-1231390c28d1.mp4\" dur=\"10s\" />" +
			"<video id=\"video_rtmp\" src=\"rtmp://media.smilkit.org/demo.mp4\" dur=\"60s\" region=\"root\" />" +
			"</seq></body></smil>";
	}
}