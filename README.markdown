SMILKit-as3
===========

SMILKit-as3 brings [SMIL 3.0][] rendering support to [Actionscript3][]. Provides an implementation of the W3C [SMIL Bostom DOM][] Working Draft specification to provide [SMIL 3.0][] DOM support.

Implements [DOM Level 2][] based on the [Xerces Java Parser][] implementation.

Compiling SMILKit and documentation
-----------------------------------

Requires Adobe [Flex SDK][] 3+, A Ruby and the Rake gem.

#### Compile everything

	rake compile:all
	
#### Compile the SMILKit library as SWC and SWF

	rake compile:lib #=> Builds the SMILKit library as SWC and SWF

#### Build documentation
	
	rake compile:docs
	
#### Package everything into a .zip for distribution (needs a compile:all before hand)

	rake package
	
Contributing
------------

[SMIL 3.0][]: http://www.w3.org/TR/SMIL3/ "SMIL 3.0"
[Actionscript3][]: http://en.wikipedia.org/wiki/ActionScript "Actionscript3"
[Flex SDK][]: http://opensource.adobe.com/wiki/display/flexsdk/Flex+SDK "Flex SDK"
[DOM Level 2]: http://www.w3.org/TR/2000/REC-DOM-Level-2-Core-20001113/ "W3C DOM Level 2"
[SMIL Bostom DOM]: http://www.w3.org/TR/smil-boston-dom/cover.html "SMIL Bostom DOM"
[Xerces Java Parser]: http://xerces.apache.org/xerces-j/apiDocs/index.html "Xerces Java Parser"


org.smilkit.w3c.dom - DOM Level 2 - http://www.w3.org/TR/2000/REC-DOM-Level-2-Core-20001113/java-binding.html
org.smilkit.w3c.dom.smil - Bostom SMIL DOM

http://www.w3.org/TR/2000/REC-DOM-Level-2-Core-20001113/ecma-script-binding.html
http://www.javadocexamples.com/org/apache/xerces/dom/org.apache.xerces.dom.ElementImpl.html
http://www.javadocexamples.com/org/apache/xerces/dom/org.apache.xerces.dom.DOMImplementationImpl.html
http://java.sun.com/j2se/1.4.2/docs/api/org/w3c/dom/Element.html

http://www.w3.org/TR/smil-boston-dom/ecma-script-binding.html
http://www.w3.org/TR/smil-boston-dom/java-binding.html
http://www.w3.org/TR/smil-boston-dom/cover.html

asdoc -doc-sources src/ -source-path src/ -main-title 'smilkit-as3' -window-title 'smilkit-as3' -output ~/Desktop/smilkit-as3/