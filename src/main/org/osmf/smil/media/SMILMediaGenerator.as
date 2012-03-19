/*****************************************************
*  
*  Copyright 2009 Akamai Technologies, Inc.  All Rights Reserved.
*  
*****************************************************
*  The contents of this file are subject to the Mozilla Public License
*  Version 1.1 (the "License"); you may not use this file except in
*  compliance with the License. You may obtain a copy of the License at
*  http://www.mozilla.org/MPL/
*   
*  Software distributed under the License is distributed on an "AS IS"
*  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
*  License for the specific language governing rights and limitations
*  under the License.
*   
*  
*  The Initial Developer of the Original Code is Akamai Technologies, Inc.
*  Portions created by Akamai Technologies, Inc. are Copyright (C) 2009 Akamai 
*  Technologies, Inc. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.smil.media
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.osmf.elements.AudioElement;
	import org.osmf.elements.CompositeElement;
	import org.osmf.elements.DurationElement;
	import org.osmf.elements.LightweightVideoElement;
	import org.osmf.elements.ParallelElement;
	import org.osmf.elements.ProxyElement;
	import org.osmf.elements.SerialElement;
	import org.osmf.elements.SoundLoader;
	import org.osmf.elements.VideoElement;
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.layout.ScaleMode;
	import org.osmf.layout.VerticalAlign;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.MediaType;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.Metadata;
	import org.osmf.net.DynamicStreamingItem;
	import org.osmf.net.DynamicStreamingResource;
	import org.osmf.net.NetStreamUtils;
	import org.osmf.net.StreamType;
	import org.osmf.net.StreamingURLResource;
	import org.osmf.smil.loader.AudioNetLoader;
	import org.osmf.smil.loader.SMILAudioElement;
	import org.osmf.smil.model.SMILAttribute;
	import org.osmf.smil.model.SMILDocument;
	import org.osmf.smil.model.SMILElement;
	import org.osmf.smil.model.SMILElementType;
	import org.osmf.smil.model.SMILLinkElement;
	import org.osmf.smil.model.SMILMediaElement;
	import org.osmf.smil.model.SMILMetaElement;
	import org.osmf.smil.model.SMILRegionElement;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.LoaderBase;
	import org.osmf.traits.MediaTraitType;
	import org.smilkit.SMILKit;
	import org.utilkit.parser.URLParser;
	import org.utilkit.util.NumberHelper;

	/**
	 * A utility class for creating MediaElements from a <code>SMILDocument</code>.
	 */
	public class SMILMediaGenerator
	{
		/**
		 * Creates the relevant MediaElement from the SMILDocument.
		 * 
		 * @param resource The original resource that was given to the load trait. 
		 * This resource might be a URLto a SMIL document, for example, and may 
		 * contain metadata we need to retain.
		 * @param smilDocument The SMILDocument to use for media creation.
		 * @returns A new MediaElement based on the information found in the SMILDocument.
		 */
		public function createMediaElement(resource:MediaResourceBase, smilDocument:SMILDocument, factory:MediaFactory):MediaElement
		{
			this.factory = factory;
			
			traceElements(smilDocument);

			var mediaElement:MediaElement;
			
			for (var i:int = 0; i < smilDocument.numElements; i++)
			{
				var smilElement:SMILElement = smilDocument.getElementAt(i);
				mediaElement = internalCreateMediaElement(resource, null, smilDocument, smilElement);
			}
							
			return mediaElement;
		}
		
		private function createMetadataFor(resource:MediaResourceBase, namespace:String, name:String, value:Object):void
		{
			var meta:Metadata = resource.getMetadataValue(namespace) as Metadata;
			
			if (meta == null)
			{
				meta = new Metadata();
				
				resource.addMetadataValue(namespace, meta);
			}
			
			meta.addValue(name, value);
		}
		
		private function createMediaMetadataFor(resource:MediaResourceBase, element:SMILMediaElement):void
		{
			if (element.params.length > 0)
			{
				var fileSize:SMILAttribute = element.getParamByName("filesize");
				
				if (fileSize != null)
				{
					this.createMetadataFor(resource, "org.smilkit.sizes", element.src, fileSize.value);
				}
			}
		}
		
		private function createStandardisedURL(url:String):String
		{
			if (url.search(/streamName=/) != -1)
			{
				var parser:URLParser = new URLParser(url);
				
				var streamName:String = parser.getParamValue("streamName");
				
				if (streamName != null && streamName != "")
				{
					return parser.hostname + "/" + parser.path + "/_definst_/" + streamName;
				}
			}
			
			return url;
		}
		
		private function createLink(mediaElement:MediaElement, element:SMILMediaElement):void
		{
			var linkElement:SMILLinkElement = element.findLinkParent();
			
			if (linkElement != null)
			{
				if (mediaElement.hasTrait(MediaTraitType.DISPLAY_OBJECT))
				{
					var displayTrait:DisplayObjectTrait = (mediaElement.getTrait(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait);
					
					displayTrait.displayObject.addEventListener(MouseEvent.CLICK, function(e:Event):void
					{
						SMILKit.logger.error("CLICK");
					});
				}
			}
		}
		
		/**
		 * Recursive function to create a media element and all of it's children.
		 */
		private function internalCreateMediaElement(originalResource:MediaResourceBase, parentMediaElement:MediaElement, 
													smilDocument:SMILDocument, smilElement:SMILElement):MediaElement
		{
			var mediaResource:MediaResourceBase = null;
			
			var mediaElement:MediaElement;
			
			switch (smilElement.type)
			{
				case SMILElementType.META:
					var metaElement:SMILMetaElement = (smilElement as SMILMetaElement);
					
					if (metaElement.name != null && metaElement.name != "")
					{
						this.createMetadataFor(originalResource, "org.smilkit", metaElement.name, metaElement.content);
					}
					break;
				case SMILElementType.SWITCH:
				case SMILElementType.EXCLUSIVE:
					mediaResource = createDynamicStreamingResource(smilElement, smilDocument);
					break;
				case SMILElementType.PARALLEL:
					var parallelElement:ParallelElement = new ParallelElement();
					mediaElement = parallelElement;
					break;
				case SMILElementType.SEQUENCE:
					var serialElement:SerialElement = new SerialElement();
					mediaElement = serialElement;
					break;
				case SMILElementType.LINK:
					var linkElement:CompositeElement = null;
					
					if (parentMediaElement is ParallelElement)
					{
						linkElement = new ParallelElement();
					}
					else
					{
						linkElement = new SerialElement();
					}
					
					mediaElement = linkElement;
					break;
				case SMILElementType.VIDEO:
					var resource:StreamingURLResource = new StreamingURLResource(this.createStandardisedURL((smilElement as SMILMediaElement).src), StreamType.LIVE_OR_RECORDED);
					resource.mediaType = MediaType.VIDEO;
					
					var videoElement:MediaElement = factory.createMediaElement(resource); // new VideoElement(resource);
					
					if (videoElement is LightweightVideoElement)
					{
						var video:LightweightVideoElement = videoElement as LightweightVideoElement;
						
						video.smoothing = true;
						video.deblocking = 1;
					}
					
					var smilVideoElement:SMILMediaElement = smilElement as SMILMediaElement;
					
					if (!isNaN(smilVideoElement.clipBegin) && smilVideoElement.clipBegin > 0 &&
					    !isNaN(smilVideoElement.clipEnd) && smilVideoElement.clipEnd > 0)
					{
						resource.clipStartTime = smilVideoElement.clipBegin;
						resource.clipEndTime = smilVideoElement.clipEnd;
					}
					
					var duration:Number = (smilElement as SMILMediaElement).duration;
					
					if (!isNaN(duration) && duration > 0)
					{
						if (videoElement is VideoElement)
						{
							(videoElement as VideoElement).defaultDuration = duration;
						}
						else if (videoElement is ProxyElement) 
						{ 
							// Try to find the proxied video element (fix for FM-1020)
							var tempMediaElement:MediaElement = videoElement;
							
							while (tempMediaElement is ProxyElement)
							{
								tempMediaElement = (tempMediaElement as ProxyElement).proxiedElement;
							}
							
							if (tempMediaElement != null && tempMediaElement is VideoElement)
							{								
								(tempMediaElement as VideoElement).defaultDuration = duration;
							}
						}
					}
					
					// add region
					var videoLayout:LayoutMetadata = this.findLayoutForRegion(smilDocument, (smilElement as SMILMediaElement).region);
					
					if (videoLayout != null)
					{
						videoElement.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, videoLayout);
						
						SMILKit.logger.debug("Video - Using Region");
					}
					
					SMILKit.logger.debug("Video Created");
					
					this.createLink(videoElement, smilElement as SMILMediaElement);
					this.createMediaMetadataFor(originalResource, smilElement as SMILMediaElement);
					
					if (parentMediaElement == null)
					{
						var parentElement:SerialElement = new SerialElement();
						mediaElement = parentElement;
						
						parentElement.addChild(videoElement);
					}
					else
					{
						(parentMediaElement as CompositeElement).addChild(videoElement);
					}
					break;
				case SMILElementType.IMAGE:
					var imageResource:URLResource = new URLResource((smilElement as SMILMediaElement).src);
					imageResource.mediaType = MediaType.IMAGE;
					
					var imageElement:MediaElement = factory.createMediaElement(imageResource);
					var dur:Number = (smilElement as SMILMediaElement).duration;
					var durationElement:DurationElement = new DurationElement(dur, imageElement);
					
					// add region
					var imageLayout:LayoutMetadata = this.findLayoutForRegion(smilDocument, (smilElement as SMILMediaElement).region);
					
					if (imageLayout != null)
					{
						durationElement.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, imageLayout);
						
						SMILKit.logger.debug("Image - Using Region");
					}
					
					this.createLink(imageElement, smilElement as SMILMediaElement);
					
					SMILKit.logger.debug("Image Created");
					
					this.createMediaMetadataFor(originalResource, smilElement as SMILMediaElement);
					
					(parentMediaElement as CompositeElement).addChild(durationElement);
					break;
				case SMILElementType.AUDIO:
					var audioResource:URLResource = new URLResource(this.createStandardisedURL((smilElement as SMILMediaElement).src));
					audioResource.mediaType = MediaType.AUDIO;
					
					var loader:LoaderBase = NetStreamUtils.isStreamingResource(audioResource) ? new AudioNetLoader() : new SoundLoader();
					var audioElement:AudioElement = new SMILAudioElement(audioResource, loader);
					audioElement.defaultDuration = (smilElement as SMILMediaElement).duration;
	
					this.createMediaMetadataFor(originalResource, smilElement as SMILMediaElement);
					
					(parentMediaElement as CompositeElement).addChild(audioElement);
					
					SMILKit.logger.debug("Audio Created");
					break;
				case SMILElementType.REGION:
					var region:SMILRegionElement = (smilElement as SMILRegionElement);
					
					SMILKit.logger.debug("Region: "+region.id+" -> "+region.width+"/"+region.height);
					break;
				case SMILElementType.REFERENCE:
					var referenceResource:URLResource = new URLResource(this.createStandardisedURL((smilElement as SMILMediaElement).src));
					var referenceElement:MediaElement = factory.createMediaElement(referenceResource);
					
					this.createMediaMetadataFor(originalResource, smilElement as SMILMediaElement);
					
					mediaResource = referenceResource;
					break;
			}
			
			if (mediaElement != null)
			{
				for (var i:int = 0; i < smilElement.numChildren; i++)
				{
					var childElement:SMILElement = smilElement.getChildAt(i);
					internalCreateMediaElement(originalResource, mediaElement, smilDocument, childElement);
				}
				
				// Fix for FM-931, make sure we support nested elements
				if (parentMediaElement is CompositeElement)
				{
					(parentMediaElement as CompositeElement).addChild(mediaElement);
				}
			}
			else if (mediaResource != null)
			{
				// Make sure we transfer any resource metadata from the original resource
				for each (var metadataNS:String in originalResource.metadataNamespaceURLs)
				{
					var metadata:Object = originalResource.getMetadataValue(metadataNS); 
					mediaResource.addMetadataValue(metadataNS, metadata);
				}
				
				mediaElement = factory.createMediaElement(mediaResource);
				
				if (parentMediaElement is CompositeElement)
				{
					(parentMediaElement as CompositeElement).addChild(mediaElement);
				}
			}
			
			return mediaElement;			
		}
		
		private function createDynamicStreamingResource(switchElement:SMILElement, smilDocument:SMILDocument):MediaResourceBase
		{
			var dsr:DynamicStreamingResource = null;
			var hostURL:String;
			
			for (var i:int = 0; i < smilDocument.numElements; i++)
			{
				var smilElement:SMILElement = smilDocument.getElementAt(i);
				
				switch (smilElement.type)
				{
					case SMILElementType.META:
						hostURL = (smilElement as SMILMetaElement).base; 
						
						if (hostURL != null)
						{
							dsr = createDynamicStreamingItems(switchElement, hostURL);
						}
						break;
				}
			}	
			
			return dsr;
		}
		
		private function createDynamicStreamingItems(switchElement:SMILElement, hostURL:String):DynamicStreamingResource
		{
			var dsr:DynamicStreamingResource = null;
			var streamItems:Vector.<DynamicStreamingItem> = new Vector.<DynamicStreamingItem>();
			
			for (var i:int = 0; i < switchElement.numChildren; i++)
			{
				var smilElement:SMILElement = switchElement.getChildAt(i);
				
				if (smilElement.type == SMILElementType.VIDEO)
				{
					var videoElement:SMILMediaElement = smilElement as SMILMediaElement;
					
					// We need to divide the bitrate by 1000 because the DynamicStreamingItem class 
					// requires the bitrate in kilobits per second.
					var dsi:DynamicStreamingItem = new DynamicStreamingItem(videoElement.src, videoElement.bitrate / 1000);
					streamItems.push(dsi);
				}
			}
			
			if (streamItems.length)
			{
				dsr = new DynamicStreamingResource(hostURL);
				dsr.streamItems = streamItems;
				dsr.streamType = StreamType.LIVE_OR_RECORDED;
			}
			
			return dsr;		
		}
		
		
		private function traceElements(smilDocument:SMILDocument):void
		{
			SMILKit.logger.debug(">>> SMILMediaGenerator.traceElements()  ");
			
			for (var i:int = 0; i < smilDocument.numElements; i++)
			{
				var smilElement:SMILElement = smilDocument.getElementAt(i);
				traceElement(smilElement)
			}	
			
			function traceElement(e:SMILElement, level:int=0):void
			{
				var levelMarker:String = "*";
				
				for (var j:int = 0; j < level; j++)
				{
					levelMarker += "*";
				}
				
				SMILKit.logger.debug(levelMarker + e.type);
				level++;
				
				for (var k:int = 0; k < e.numChildren; k++)
				{
					traceElement(e.getChildAt(k), level);
				}
				
				level--;
			}
		}
		
		private function findLayoutForRegion(document:SMILDocument, regionId:String):LayoutMetadata
		{
			var region:SMILRegionElement = document.getRegionByName(regionId);
			
			if (region != null && region.id == regionId)
			{
				var layout:LayoutMetadata = new LayoutMetadata();
				
				layout.verticalAlign = VerticalAlign.MIDDLE;
				layout.scaleMode = ScaleMode.LETTERBOX;
				
				if (region.width != null)
				{
					if (!NumberHelper.isPercentage("%")) layout.width = parseInt(region.width);
					else layout.percentWidth = NumberHelper.percentageToInteger(region.width);
				}
				
				if (region.height != null) 
				{
					if (!NumberHelper.isPercentage("%")) layout.height = parseInt(region.height);
					else layout.percentHeight = NumberHelper.percentageToInteger(region.height);
				}
				
				if (region.left != null) layout.left = parseFloat(region.left);
				if (region.right != null) layout.right = parseFloat(region.right);
				if (region.top != null) layout.top = parseFloat(region.top);
				if (region.bottom != null) layout.bottom = parseFloat(region.bottom);
				
				if (region.index != null) layout.index = parseInt(region.index);
				
				return layout;
			}
			
			return null;
		}

		private var factory:MediaFactory;
	}
}
