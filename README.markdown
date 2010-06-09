SMILKit
=======

SMILKit is an parsing and rendering engine for [SMIL 3.0][].  SMILKit is a general architecture which is implemented in language specific projects.  SMILKit's first implementation will be SMILKit-as3, a pure [Actionscript3][] implementation. SMILKit-as3 targets Flash Player 10.0 and higher.

Documentation
=============

Compiling SMILKit-as3
=====================

Requires Adobe [Flex SDK][] 4+ and ANT.

Needs to have `FLEX_HOME` defined in your environment variables, should point to your Flex SDK. `FLEX_HOME` should always be defined as an absolute path. Defining `FLEX_HOME` relative to the current working directory or relative to your home directory will result in errors. Define `FLEX_HEADLESS` as `true` when building on Linux headless servers (via [xVNC][]).



#### Full build, test and produce reports + docs

	ant build
	

#### Test

	ant test
	

You should have the [Flash 10 debug player](http://www.adobe.com/support/flashplayer/downloads.html#fp10) and the [Flash 10 Standalone player](http://download.macromedia.com/pub/flashplayer/updaters/10/flashplayer_10_sa_debug.app.zip) installed before attempting to run the tests.

#### Generate ASDocs

	ant asdocs
	

#### Package everything into a .zip for distribution (needs a `build` before hand)

	ant package
	
Contributing
------------

Authors
-------

License
-------

[SMIL 3.0]: http://www.w3.org/TR/SMIL3/ "SMIL 3.0"
[Actionscript3]: http://en.wikipedia.org/wiki/ActionScript "Actionscript3"
[Flex SDK]: http://opensource.adobe.com/wiki/display/flexsdk/Flex+SDK "Flex SDK"
[DOM Level 2]: http://www.w3.org/TR/2000/REC-DOM-Level-2-Core-20001113/ "W3C DOM Level 2"
[Boston DOM]: http://www.w3.org/TR/smil-boston-dom/cover.html "Boston DOM"
[Xerces Java Parser]: http://xerces.apache.org/xerces-j/apiDocs/index.html "Xerces Java Parser"
[xVNC]: http://xvnc.sourceforge.net/ "xVNC"