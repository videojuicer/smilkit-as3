package org.smilkit.spec
{
	public class Fixtures
	{
		public static var BASIC_SMIL_XML:String = "<?xml version=\"1.0\"?><smil>" +
			"<head><layout><region xml:id=\"root\" width=\"100%\" height=\"100%\" /></layout></head>" +
			"<body id=\"body\"><video id=\"content\" src=\"http://cloud.sixones.com/family-guy-trailer.mp4\" region=\"root\" /></body></smil>";
		
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
		
		public static var BASIC_UNRESOLVED_SMIL_XML:String = "<?xml version=\"1.0\"?><smil>" +
			"<head><layout><region xml:id=\"left\" width=\"50%\" height=\"100%\" /><region xml:id=\"right\" right=\"0\" width=\"50%\" height=\"100%\" /></layout></head>" +
			"<body><par>"+
			"<seq id=\"left\">" +
			"<video id=\"preroll_left\" src=\"http://cloud.sixones.com/family-guy-trailer.mp4\"  region=\"left\" />" +
			"<video id=\"content_left\" src=\"http://media.smilkit.org/demo.mp4\" region=\"left\" />" +
			"</seq>"+
			"<seq id=\"right\">" +
			"<img id=\"preroll_right\" src=\"http://cloud.sixones.com/family-guy-trailer.mp4\" region=\"right\" />" +
			"<video id=\"content_right\" src=\"http://media.smilkit.org/demo.mp4\" region=\"right\" />" +
			"</seq>"+
			"</par></body></smil>";
	}
}