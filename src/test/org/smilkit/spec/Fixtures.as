package org.smilkit.spec
{
	public class Fixtures
	{
		public static var BASIC_SMIL_XML:String = "<?xml version=\"1.0\"?><smil>" +
			"<head><layout><region xml:id=\"root\" width=\"100%\" height=\"100%\" /></layout></head>" +
			"<body id=\"body\"><video id=\"content\" dur=\"10s\" src=\"http://cloud.sixones.com/family-guy-trailer.mp4\" region=\"root\" /></body></smil>";
		
		public static var BASIC_SEQ_SMIL_XML:String = "<?xml version=\"1.0\"?><smil>" +
			"<head><layout><region xml:id=\"root\" width=\"100%\" height=\"100%\" /></layout></head>" +
			"<body><seq id=\"holder\">" +
			"<video id=\"preroll\" dur=\"10s\" src=\"http://cloud.sixones.com/family-guy-trailer.mp4\" />" +
			"<video id=\"content\" src=\"http://media.smilkit.org/demo.mp4\" dur=\"60s\" region=\"root\" />" +
			"<video id=\"postroll\" src=\"http://media.smilkit.org/postroll.mp4\" dur=\"10s\" region=\"root\" />" +
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
			"<img id=\"preroll_right\" src=\"http://sixty.im/DecodedBase64.jpg\" region=\"right\" />" +
			"<video id=\"content_right\" src=\"http://media.smilkit.org/demo.mp4\" region=\"right\" />" +
			"</seq>"+
			"</par></body></smil>";
		
		public static var MULTIPLE_CHILDREN_SMIL_XML:String = "<?xml version=\"1.0\"?><smil>" +
			"<head>"+
			"<metadata name=\"title\" content=\"Hello World!\" />"+
			"<metadata name=\"version\" content=\"2\" />"+
			"<metadata name=\"count\" content=\"6\" />"+
			"<layout><region xml:id=\"left\" width=\"50%\" height=\"100%\" /><region xml:id=\"right\" right=\"0\" width=\"50%\" height=\"100%\" /></layout></head>" +
			"<body><par id=\"holder\">"+
			"<seq id=\"left\">" +
			"<video id=\"preroll_left\" src=\"http://cloud.sixones.com/family-guy-trailer.mp4\"  region=\"left\" />" +
			"<video id=\"content_left\" src=\"http://media.smilkit.org/demo.mp4\" region=\"left\" />" +
			"</seq>"+
			"<seq id=\"middle\">" +
			"<img id=\"preroll_middle\" src=\"http://sixty.im/DecodedBase64.jpg\" region=\"right\" />" +
			"<video id=\"content_middle\" src=\"http://media.smilkit.org/demo.mp4\" region=\"right\" />" +
			"</seq>"+
			"<seq id=\"middle_two\">" +
			"<img id=\"preroll_middle_two\" src=\"http://sixty.im/DecodedBase64.jpg\" region=\"right\" />" +
			"<video id=\"content_middle_two\" src=\"http://media.smilkit.org/demo.mp4\" region=\"right\" />" +
			"</seq>"+
			"<seq id=\"right\">" +
			"<img id=\"preroll_right\" src=\"http://sixty.im/DecodedBase64.jpg\" region=\"right\" />" +
			"<video id=\"content_right\" src=\"http://media.smilkit.org/demo.mp4\" region=\"right\" />" +
			"</seq>"+
			"</par></body></smil>";
		
		public static var BASIC_REFERENCE_SMIL_XML:String = "<?xml version=\"1.0\"?><smil>" +
			"<head><layout><region xml:id=\"root\" width=\"100%\" height=\"100%\" /></layout></head>" +
			"<body>"+
				"<ref id=\"reference_tag\" type=\"application/smil\" src=\"http://assets-fms.staging.videojuicer.net/demo/d07fc2a4-a21b-11de-a4ab-123139025d32.mp4.smil\" />"+
			"</body></smil>";
			
		public static var REFERENCE_IN_SEQUENCE_SMIL_XML:String = 	"<?xml version=\"1.0\"?><smil>" +
			"<head><layout><region xml:id=\"root\" width=\"100%\" height=\"100%\" /></layout></head>" +
			"<body>"+
				"<seq>"+
					"<ref id=\"reference_tag\" type=\"application/smil\" dur=\"10s\" src=\"http://assets-fms.staging.videojuicer.net/demo/d07fc2a4-a21b-11de-a4ab-123139025d32.mp4.smil\" />"+
					"<video id=\"post_reference_video\" src=\"http://cloud.sixones.com/family-guy-trailer.mp4\"  region=\"root\" />"+
				"</seq>"+
			"</body></smil>";
			
		public static var BASIC_LINK_CONTEXT_SMIL_XML:String = "<?xml version=\"1.0\"?><smil>" +
			"<head><layout><region xml:id=\"root\" width=\"100%\" height=\"100%\" /></layout></head>" +
			"<body>"+
				"<a href=\"http://foo.com/direct\" id=\"directlink\"><video id=\"direct\" src=\"http://media.smilkit.org/demo.mp4\" /></a>"+
				"<a href=\"http://foo.com/uptree\" id=\"uptreelink\"><seq><seq><video id=\"uptree\" src=\"http://media.smilkit.org/demo.mp4\" /></seq></seq></a>"+
				"<video id=\"notwrapped\" src=\"http://media.smilkit.org/demo.mp4\" />"+
			"</body></smil>";
		
		public static var TIME_CHILDREN_SMIL_XML:String = "<?xml version=\"1.0\"?><smil>" +
			"<head><layout><region xml:id=\"left\" width=\"50%\" height=\"100%\" /><region xml:id=\"right\" right=\"0\" width=\"50%\" height=\"100%\" /></layout></head>" +
			"<body>"+
			"<seq id=\"left\">" +
				"<video id=\"preroll_left\" src=\"http://cloud.sixones.com/family-guy-trailer.mp4\"  region=\"left\" />" +
				"<video id=\"content_left\" src=\"http://media.smilkit.org/demo.mp4\" region=\"left\" />" +
			"</seq>"+
			"<a />"+
			"<ref id=\"content\">"+
				"<smil>"+
				"<body>"+
					"<seq>"+
						"<video id=\"content_trailer\" src=\"http://cloud.sixones.com/family-guy-trailer.mp4\"  region=\"left\" />" +
					"</seq>"+
				"</body>"+
				"</smil>"+
			"</ref>"+
			"<seq id=\"middle\">" +
				"<img id=\"preroll_middle\" src=\"http://sixty.im/DecodedBase64.jpg\" region=\"right\" />" +
				"<video id=\"content_middle\" src=\"http://media.smilkit.org/demo.mp4\" region=\"right\" />" +
			"</seq>"+
			"</body></smil>";
			
		public static var METADATA_SMIL_XML:String = "<?xml version=\"1.0\"?><smil>" +
			"<head><meta name=\"fookey\" content=\"foovalue\" /><meta name=\"barkey\" content=\"barvalue\" /><layout>"+
			"<region xml:id=\"root\" width=\"100%\" height=\"100%\" /></layout></head>" +
			"<body id=\"body\"><video id=\"content\" dur=\"10s\" src=\"http://cloud.sixones.com/family-guy-trailer.mp4\" region=\"root\" /></body></smil>";
			
		public static var BEGIN_TIME_SMIL_XML:String = "<?xml version=\"1.0\"?><smil>" +
  			"<head><layout><region xml:id=\"root\" width=\"100%\" height=\"100%\" /></layout></head>"+
  			"<body id=\"body\"><video id=\"content\" begin=\"5s\" dur=\"10s\" src=\"http://cloud.sixones.com/family-guy-trailer.mp4\" region=\"root\" /></body></smil>";
	
		public static var RESOLVED_VIDEOS_IN_A_SEQ_SMIL_XML:String = "<?xml version=\"1.0\"?><smil>" +
			"<head><layout><region xml:id=\"root\" width=\"100%\" height=\"100%\" /></layout></head>" +
			"<body>" +
			"<seq>                                       " +
				"<video id=\"video_1\" dur=\"30s\" src=\"1.mp4\" />" +
				"<video id=\"video_2\" dur=\"30s\" src=\"2.mp4\" />" +
			"</seq>                                      " +
			"</body></smil>";
		
		public static var RESOLVED_VIDEOS_IN_A_PAR_SMIL_XML:String = "<?xml version=\"1.0\"?><smil>" +
			"<head><layout><region xml:id=\"root\" width=\"100%\" height=\"100%\" /></layout></head>" +
			"<body>" +
			"<par>                                       " +
				"<video id=\"video_1\" dur=\"30s\" src=\"1.mp4\" />" +
				"<video id=\"video_2\" dur=\"35s\" src=\"2.mp4\" />" +
			"</par>                                      " +
			"</body></smil>";
		
		public static var PARENT_SEQ_SETS_DURATION_SMIL_XML:String = "<?xml version=\"1.0\"?><smil>" +
			"<head><layout><region xml:id=\"root\" width=\"100%\" height=\"100%\" /></layout></head>" +
			"<body>" +
			"<seq dur=\"40s\">                             " +
				"<video id=\"video_1\" dur=\"30s\" src=\"1.mp4\" />" +
				"<video id=\"video_2\" dur=\"30s\" src=\"2.mp4\" />" +
			"</seq>                                      " +
			"</body></smil>";
		
		public static var PARENT_PAR_SETS_DURATION_SMIL_XML:String = "<?xml version=\"1.0\"?><smil>" +
			"<head><layout><region xml:id=\"root\" width=\"100%\" height=\"100%\" /></layout></head>" +
			"<body>" +
			"<par dur=\"40s\">                             " +
				"<video id=\"video_1\" dur=\"30s\" src=\"1.mp4\" />" +
				"<video id=\"video_2\" dur=\"60s\" src=\"2.mp4\" />" +
			"</par>                                      " +
			"</body></smil>";
		
		public static var PARENT_CROPS_LAST_CHILD_SMIL_XML:String = "<?xml version=\"1.0\"?><smil>" +
			"<head><layout><region xml:id=\"root\" width=\"100%\" height=\"100%\" /></layout></head>" +
			"<body>" +
			"<par dur=\"40s\">                             " +
			"<video id=\"video_1\" dur=\"30s\" src=\"1.mp4\" />" +
			"<video id=\"video_2\" dur=\"60s\" src=\"2.mp4\" />" +
			"</par>                                      " +
			"<par dur=\"40s\">                             " +
			"<video id=\"video_3\" dur=\"30s\" src=\"1.mp4\" />" +
			"<video id=\"video_4\" dur=\"60s\" src=\"2.mp4\" />" +
			"</par>                                      " +
			"</body></smil>";
		
		public static var UNRESOLVED_CHILD_SETS_DUR_IN_SEQ_SMIL_XML:String = "<?xml version=\"1.0\"?><smil>" +
			"<head><layout><region xml:id=\"root\" width=\"100%\" height=\"100%\" /></layout></head>" +
			"<body>" +
			"<seq>                                       " +
				"<video id=\"video_1\" dur=\"30s\" src=\"1.mp4\" />" +
				"<video id=\"video_2\" src=\"2.mp4\" />          " +
			"</seq>                                      " +
			"</body></smil>";
		
		public static var UNRESOLVED_CHILD_SETS_DUR_IN_PAR_SMIL_XML:String = "<?xml version=\"1.0\"?><smil>" +
			"<head><layout><region xml:id=\"root\" width=\"100%\" height=\"100%\" /></layout></head>" +
			"<body>" +
			"<par>                                       " +
				"<video id=\"video_1\" dur=\"30s\" src=\"1.mp4\" />" +
				"<video id=\"video_2\" src=\"2.mp4\" />          " +
			"</par>                                      " +
			"</body></smil>";
		
		public static var UNRESOLVED_CHILD_SETS_DUR_IN_REF_SMIL_XML:String = "<?xml version=\"1.0\"?><smil>" +
			"<head><layout><region xml:id=\"root\" width=\"100%\" height=\"100%\" /></layout></head>" +
			"<body>" +
			"<ref>                                       " +
			"<video id=\"video_1\" dur=\"30s\" src=\"1.mp4\" />" +
			"<video id=\"video_2\" src=\"2.mp4\" />          " +
			"</ref>                                      " +
			"</body></smil>";
		
		public static var REF_AND_BASE_TAGS_SMIL_XML:String = "<?xml version=\"1.0\"?><smil>" +
			"<head><layout><region xml:id=\"root\" width=\"100%\" height=\"100%\" /></layout><meta base=\"http://hello\" /></head>" +
			"<body>" +
				"<smil><head><meta base=\"http://world\" /></head><body>" +
					"<video id=\"video_2\" dur=\"30s\" src=\"2.mp4\" />" +
				"</body></smil>" +
			"<video id=\"video_1\" dur=\"30s\" src=\"1.mp4\" />" +
			"</body></smil>";
			
		public static var REF_SEQUENCE_SMIL_XML:String = "<?xml version=\"1.0\"?><smil>" +
				"<head><layout><region xml:id=\"root\" width=\"100%\" height=\"100%\" /></layout></head>" +
				"<body>"+
					"<seq>"+
						"<ref id=\"reference_one\" type=\"application/smil\" src=\"http://foo.com/one.smil\" />"+
						"<ref id=\"reference_bar\" type=\"application/smil\" src=\"http://foo.com/two.smil\" />"+
					"</seq>"+
				"</body></smil>";
				
		public static var REF_SEQUENCE_INNER_SMIL_XML:String = "<?xml version=\"1.0\"?><smil>" +
				"<head><layout><region xml:id=\"root\" width=\"100%\" height=\"100%\" /></layout></head>" +
				"<body>"+
					"<seq>"+
						"<video src=\"http://foo.com/video.mp4\" />"+
					"</seq>"+
				"</body></smil>";
				
		public static var ELEMENT_TEST_SMIL_XML:String = "<?xml version=\"1.0\"?><smil>" +
			"<head><layout><region xml:id=\"root\" width=\"100%\" height=\"100%\" /></layout></head>" +
			"<body>"+
				"<seq>"+
					"<video id=\"empty\" />"+
				
					"<video id=\"systemAudioDesc\" systemAudioDesc=\"off\" />"+
					"<video id=\"systemBaseProfile\" systemBaseProfile=\"\" />"+
					"<video id=\"systemBitrate\" systemBitrate=\"56000\" />"+
					"<video id=\"systemCaptions\" systemCaptions=\"off\" />"+
					"<video id=\"systemComponent\" systemComponent=\"\" />"+
					"<video id=\"systemContentLocation\" systemContentLocation=\"\" />"+
					"<video id=\"systemCPU\" systemCPU=\"x64\" />"+
					"<video id=\"systemLanguage\" systemLanguage=\"\" />"+
					"<video id=\"systemOperatingSystem\" systemOperatingSystem=\"linux\" />"+
					"<video id=\"systemOverdubOrCaption\" systemOverdubOrCaption=\"caption\" />"+
					"<video id=\"systemOverdubOrSubtitle\" systemOverdubOrSubtitle=\"subtitle\" />"+
					"<video id=\"systemRequired\" systemRequired=\"\" />"+
					"<video id=\"systemScreenDepth\" systemScreenDepth=\"32\" />"+
					"<video id=\"systemScreenSize\" systemScreenSize=\"1680x1520\" />"+
					"<video id=\"systemVersion\" systemVersion=\"3.0\" />"+
					
					"<video id=\"double_test\" systemVersion=\"\" systemCPU=\"\" />"+
					
					"<video id=\"fail_systemAudioDesc\" systemAudioDesc=\"on\" />"+
					"<video id=\"fail_systemBaseProfile\" systemBaseProfile=\"Daisy\" />"+
					"<video id=\"fail_systemBitrate\" systemBitrate=\"5600000\" />"+
					"<video id=\"fail_systemCaptions\" systemCaptions=\"on\" />"+
					"<video id=\"fail_systemComponent\" systemComponent=\"booooom\" />"+
					"<video id=\"fail_systemContentLocation\" systemContentLocation=\"STORAGE\" />"+
					"<video id=\"fail_systemCPU\" systemCPU=\"arm\" />"+
					"<video id=\"fail_systemLanguage\" systemLanguage=\"fr\" />"+
					"<video id=\"fail_systemOperatingSystem\" systemOperatingSystem=\"windows\" />"+
					"<video id=\"fail_systemOverdubOrCaption\" systemOverdubOrCaption=\"overdub\" />"+
					"<video id=\"fail_systemOverdubOrSubtitle\" systemOverdubOrSubtitle=\"overdub\" />"+
					"<video id=\"fail_systemRequired\" systemRequired=\"DaisyChain\" />"+
					"<video id=\"fail_systemScreenDepth\" systemScreenDepth=\"64\" />"+
					"<video id=\"fail_systemScreenSize\" systemScreenSize=\"10240x51020\" />"+
					"<video id=\"fail_systemVersion\" systemVersion=\"4.0\" />"+
				"</seq>"+
			"</body></smil>";
	}
}