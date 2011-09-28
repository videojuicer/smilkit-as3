/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version 1.1
 * (the "License"); you may not use this file except in compliance with the
 * License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 *
 * The Original Code is the SMILKit library.
 *
 * The Initial Developer of the Original Code is
 * Videojuicer Ltd. (UK Registered Company Number: 05816253).
 * Portions created by the Initial Developer are Copyright (C) 2010
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 * 	Dan Glegg
 * 	Adam Livesley
 *
 * ***** END LICENSE BLOCK ***** */
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

		public static var BASIC_SWITCH_SMIL_XML:String = "<?xml version=\"1.0\"?><smil>" +
			"<head><layout><region xml:id=\"root\" width=\"100%\" height=\"100%\" /></layout></head>" +
			"<body><par id=\"holder\">" +
				"<switch id=\"switch_block\">" +
					"<img systemVersion=\"3.0\" region=\"root\" dur=\"5s\" />" +
					"<img systemVersion=\"2.0\" region=\"root\" dur=\"5s\" />" +
					"<img region=\"root\" dur=\"5s\" />" +
				"</switch>" +
			"</par></body></smil>";
		
		public static var EXTENDED_SWITCH_SMIL_XML:String = "<?xml version=\"1.0\"?><smil>" +
			"<head><layout><region xml:id=\"root\" width=\"100%\" height=\"100%\" /></layout></head>" +
			"<body><par id=\"holder\">" +
				"<switch id=\"switch_block\">" +
					"<blah />" +
					"<a href=\"http://videojuicer.com\" />" +
					"<img systemVersion=\"3.0\" region=\"root\" dur=\"5s\" />" +
					"<img systemVersion=\"2.0\" region=\"root\" dur=\"5s\" />" +
					"<img region=\"root\" dur=\"5s\" />" +
				"</switch>" +
			"</par></body></smil>";
		
		public static var MP4_VIDEO_SMIL_XML:String =  "<?xml version=\"1.0\"?><smil>" +
			"<head><layout><region xml:id=\"root\" width=\"100%\" height=\"100%\" /></layout></head>" +
			"<body><seq id=\"holder\">" +
			"<video id=\"video_http\" src=\"http://assets.videojuicer.net/smilkit/bcf93ccc-7e18-11df-a68c-1231390c28d1.mp4\" dur=\"10s\">"+
			"<param name=\"filesize\" value=\"1000\"/>"+
			"</video>" +
			"<video id=\"video_rtmp\" src=\"rtmp://media.smilkit.org/demo.mp4\" dur=\"60s\" region=\"root\" />" +
			"</seq></body></smil>";
		
		public static var BASIC_UNRESOLVED_SMIL_XML:String = "<?xml version=\"1.0\"?><smil>" +
			"<head><layout><region xml:id=\"left\" width=\"50%\" height=\"100%\" /><region xml:id=\"right\" right=\"0\" width=\"50%\" height=\"100%\" /></layout></head>" +
			"<body>"+
			"<par>"+
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
			"<par id=\"cropped_holder\" dur=\"40s\">                             " +
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
				"<par>"+
					"<video dur=\"5s\" id=\"empty\" src=\"http://smilkit.org/demo.mp4\" />"+
				
					"<video dur=\"5s\" id=\"systemAudioDesc\" systemAudioDesc=\"off\" src=\"http://smilkit.org/demo.mp4\" />"+
					"<video dur=\"5s\" id=\"systemBaseProfile\" systemBaseProfile=\"\" src=\"http://smilkit.org/demo.mp4\" />"+
					"<video dur=\"5s\" id=\"systemBitrate\" systemBitrate=\"56000\" src=\"http://smilkit.org/demo.mp4\" />"+
					"<video dur=\"5s\" id=\"systemCaptions\" systemCaptions=\"off\" src=\"http://smilkit.org/demo.mp4\" />"+
					"<video dur=\"5s\" id=\"systemComponent\" systemComponent=\"\" src=\"http://smilkit.org/demo.mp4\" />"+
					"<video dur=\"5s\" id=\"systemContentLocation\" systemContentLocation=\"\" src=\"http://smilkit.org/demo.mp4\" />"+
					"<video dur=\"5s\" id=\"systemCPU\" systemCPU=\"x64\" src=\"http://smilkit.org/demo.mp4\" />"+
					"<video dur=\"5s\" id=\"systemLanguage\" systemLanguage=\"\" src=\"http://smilkit.org/demo.mp4\" />"+
					"<video dur=\"5s\" id=\"systemOperatingSystem\" systemOperatingSystem=\"linux\" src=\"http://smilkit.org/demo.mp4\" />"+
					"<video dur=\"5s\" id=\"systemOverdubOrCaption\" systemOverdubOrCaption=\"caption\" src=\"http://smilkit.org/demo.mp4\" />"+
					"<video dur=\"5s\" id=\"systemOverdubOrSubtitle\" systemOverdubOrSubtitle=\"subtitle\" src=\"http://smilkit.org/demo.mp4\" />"+
					"<video dur=\"5s\" id=\"systemRequired\" systemRequired=\"\" src=\"http://smilkit.org/demo.mp4\" />"+
					"<video dur=\"5s\" id=\"systemScreenDepth\" systemScreenDepth=\"32\" src=\"http://smilkit.org/demo.mp4\" />"+
					"<video dur=\"5s\" id=\"systemScreenSize\" systemScreenSize=\"1680x1520\" src=\"http://smilkit.org/demo.mp4\" />"+
					"<video dur=\"5s\" id=\"systemVersion\" systemVersion=\"3.0\" src=\"http://smilkit.org/demo.mp4\" />"+
					
					"<video dur=\"5s\" id=\"double_test\" systemVersion=\"\" systemCPU=\"\" src=\"http://smilkit.org/demo.mp4\" />"+
					
					"<video dur=\"5s\" id=\"fail_systemAudioDesc\" systemAudioDesc=\"on\" src=\"http://smilkit.org/demo.mp4\" />"+
					"<video dur=\"5s\" id=\"fail_systemBaseProfile\" systemBaseProfile=\"Daisy\" src=\"http://smilkit.org/demo.mp4\" />"+
					"<video dur=\"5s\" id=\"fail_systemBitrate\" systemBitrate=\"5600000\" src=\"http://smilkit.org/demo.mp4\" />"+
					"<video dur=\"5s\" id=\"fail_systemCaptions\" systemCaptions=\"on\" src=\"http://smilkit.org/demo.mp4\" />"+
					"<video dur=\"5s\" id=\"fail_systemComponent\" systemComponent=\"booooom\" src=\"http://smilkit.org/demo.mp4\" />"+
					"<video dur=\"5s\" id=\"fail_systemContentLocation\" systemContentLocation=\"STORAGE\" src=\"http://smilkit.org/demo.mp4\" />"+
					"<video dur=\"5s\" id=\"fail_systemCPU\" systemCPU=\"arm\" src=\"http://smilkit.org/demo.mp4\" />"+
					"<video dur=\"5s\" id=\"fail_systemLanguage\" systemLanguage=\"fr\" src=\"http://smilkit.org/demo.mp4\" />"+
					"<video dur=\"5s\" id=\"fail_systemOperatingSystem\" systemOperatingSystem=\"windows\" src=\"http://smilkit.org/demo.mp4\" />"+
					"<video dur=\"5s\" id=\"fail_systemOverdubOrCaption\" systemOverdubOrCaption=\"overdub\" src=\"http://smilkit.org/demo.mp4\" />"+
					"<video dur=\"5s\" id=\"fail_systemOverdubOrSubtitle\" systemOverdubOrSubtitle=\"overdub\" src=\"http://smilkit.org/demo.mp4\" />"+
					"<video dur=\"5s\" id=\"fail_systemRequired\" systemRequired=\"DaisyChain\" src=\"http://smilkit.org/demo.mp4\" />"+
					"<video dur=\"5s\" id=\"fail_systemScreenDepth\" systemScreenDepth=\"64\" src=\"http://smilkit.org/demo.mp4\" />"+
					"<video dur=\"5s\" id=\"fail_systemScreenSize\" systemScreenSize=\"10240x51020\" src=\"http://smilkit.org/demo.mp4\" />"+
					"<video dur=\"5s\" id=\"fail_systemVersion\" systemVersion=\"4.0\" src=\"http://smilkit.org/demo.mp4\" />"+
					
					"<video dur=\"5s\" id=\"booleanExpression\" expr=\"10.0 == 10.0\" src=\"http://smilkit.org/demo.mp4\" />"+
					"<video dur=\"5s\" id=\"fail_booleanExpression\" expr=\"4 == 3\" src=\"http://smilkit.org/demo.mp4\" />"+
				"</par>"+
			"</body></smil>";
		
		public static var ELEMENT_BASIC_TEST_SMIL_XML:String = "<?xml version=\"1.0\"?><smil>" +
			"<head><layout><region xml:id=\"root\" width=\"100%\" height=\"100%\" /></layout></head>" +
			"<body>"+
			"<par>"+
				"<video dur=\"5s\" id=\"systemAudioDesc\" systemAudioDesc=\"off\" src=\"http://smilkit.org/demo.mp4\" />"+
				"<video dur=\"5s\" id=\"systemVersion\" systemVersion=\"3.0\" src=\"http://smilkit.org/demo.mp4\" />"+

				"<video dur=\"5s\" id=\"fail_systemCaptions\" systemCaptions=\"on\" src=\"http://smilkit.org/demo.mp4\" />"+
				"<video dur=\"5s\" id=\"fail_systemComponent\" systemComponent=\"booooom\" src=\"http://smilkit.org/demo.mp4\" />"+
				"<video dur=\"5s\" id=\"fail_systemContentLocation\" systemContentLocation=\"STORAGE\" src=\"http://smilkit.org/demo.mp4\" />"+
				"<video dur=\"5s\" id=\"fail_systemCPU\" systemCPU=\"arm\" src=\"http://smilkit.org/demo.mp4\" />"+
				"<video dur=\"5s\" id=\"fail_systemLanguage\" systemLanguage=\"fr\" src=\"http://smilkit.org/demo.mp4\" />"+
				"<video dur=\"5s\" id=\"fail_systemRequired\" systemRequired=\"DaisyChain\" src=\"http://smilkit.org/demo.mp4\" />"+
				"<video dur=\"5s\" id=\"fail_systemScreenDepth\" systemScreenDepth=\"64\" src=\"http://smilkit.org/demo.mp4\" />"+
				"<video dur=\"5s\" id=\"fail_systemScreenSize\" systemScreenSize=\"10240x51020\" src=\"http://smilkit.org/demo.mp4\" />"+
				"<video dur=\"5s\" id=\"fail_systemVersion\" systemVersion=\"4.0\" src=\"http://smilkit.org/demo.mp4\" />"+
			
				"<video dur=\"5s\" id=\"booleanExpression\" expr=\"10.0 == 10.0\" src=\"http://smilkit.org/demo.mp4\" />"+
				"<video dur=\"5s\" id=\"fail_booleanExpression\" expr=\"4 == 3\" src=\"http://smilkit.org/demo.mp4\" />"+
			"</par>"+
			"</body></smil>";
		
		public static var BASIC_PAR_TIME_TEST_SMIL_XML:String = "<?xml version=\"1.0\"?><smil>" +
			"<head><layout><region xml:id=\"root\" width=\"100%\" height=\"100%\" /></layout></head>" +
			"<body>" +
			"<par id=\"holder\">" +
			"<video id=\"content\" dur=\"10s\" begin=\"0s;10s;20s\" src=\"1.mp4\" />" +
			"<video id=\"content_2\" dur=\"10s\" src=\"1.mp4\" />" +
			"</par>                                      " +
			"</body></smil>";
		
		public static var BASIC_SEQ_TIME_TEST_SMIL_XML:String = "<?xml version=\"1.0\"?><smil>" +
			"<head><layout><region xml:id=\"root\" width=\"100%\" height=\"100%\" /></layout></head>" +
			"<body>" +
			"<seq id=\"holder\">" +
			"<video id=\"content\" dur=\"10s\" begin=\"0s;10s;20s\" src=\"1.mp4\" />" +
			"<video id=\"content_2\" dur=\"10s\" src=\"1.mp4\" />" +
			"</seq>                                      " +
			"</body></smil>";
		
		public static var BASIC_REPEATS_TEST_SMIL_XML:String = "<?xml version=\"1.0\"?><smil>" +
			"<head><layout><region xml:id=\"root\" width=\"100%\" height=\"100%\" /></layout></head>" +
			"<body>" +
			"<video id=\"repeatDur\" repeatDur=\"100s\" dur=\"10s\" src=\"1.mp4\" />" +
			"<video id=\"repeatCount\" repeatCount=\"10\" dur=\"10s\" src=\"1.mp4\" />" +
			"<video id=\"repeatBoth\" repeatCount=\"9\" repeatDur=\"110s\" dur=\"10s\" src=\"1.mp4\" />" +
			"<video id=\"repeatBothReverse\" repeatCount=\"11\" repeatDur=\"90s\" dur=\"10s\" src=\"1.mp4\" />" +
			"</body></smil>"; 
			
		public static var PARAMS_SMIL_XML:String = 	"<?xml version=\"1.0\"?><smil>" +
				"<head>"+
				"<paramGroup xml:id=\"group1\"><param name=\"foo\" value=\"foo-group1\" /><param name=\"bar\" value=\"bar-group1\" /></paramGroup>"+
				"<paramGroup xml:id=\"group2\"><param name=\"foo\" value=\"foo-group2\" /><param name=\"bar\" value=\"bar-group2\" /></paramGroup>"+
				"<layout><region xml:id=\"root\" width=\"100%\" height=\"100%\" /></layout></head>" +
				"<body>" +
				"<seq id=\"holder\">" +
				"<video id=\"group_params\" src=\"1.mp4\" paramGroup=\"group1\" />" +
				"<video id=\"mixed_params\" src=\"1.mp4\" paramGroup=\"group2\"><param name=\"bar\" value=\"bar-local\" /><param name=\"baz\" value=\"baz-local\" /></video>" +
				"<video id=\"local_params\" dur=\"10s\" src=\"1.mp4\"><param name=\"foo\" value=\"foo-local\" /></video>" +
				"</seq>                                      " +
				"</body></smil>";
	}
}