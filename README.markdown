SMILKit-as3
===========

SMILKit-as3 brings [SMIL 3][] rendering support to [Actionscript3][]. Provides an implementation of the W3C [SMIL Bostom DOM][] Working Draft specification to provide [SMIL 3][] DOM support.

Implements [DOM Level 2][] based on the [Xerces Java Parser][] implementation.

Compiling SMILKit and documentation
-----------------------------------

Requires Adobe [Flex SDK][] 4+ and ANT.

Needs to have `FLEX_HOME` defined in your environment variables, should point to your Flex SDK.
Define `FLEX_HEADLESS` as `true` when building on Linux headless servers (via XVNC)\

#### Full build and test

	ant build
	
#### Test

	ant test
	
#### Package everything into a .zip for distribution (needs a `build` before hand)

	ant package
	
Contributing
------------

Authors
-------

License
-------

[SMIL 3][]: http://www.w3.org/TR/SMIL3/ "SMIL 3.0"
[Actionscript3][]: http://en.wikipedia.org/wiki/ActionScript "Actionscript3"
[Flex SDK][]: http://opensource.adobe.com/wiki/display/flexsdk/Flex+SDK "Flex SDK"
[DOM Level 2]: http://www.w3.org/TR/2000/REC-DOM-Level-2-Core-20001113/ "W3C DOM Level 2"
[SMIL Bostom DOM]: http://www.w3.org/TR/smil-boston-dom/cover.html "SMIL Bostom DOM"
[Xerces Java Parser]: http://xerces.apache.org/xerces-j/apiDocs/index.html "Xerces Java Parser"