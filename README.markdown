SMILKit
=======

SMILKit is an parsing and rendering engine for [SMIL 3.0][].  SMILKit is a general architecture which is implemented in language specific projects.  SMILKit's first implementation will be SMILKit-as3, a pure [Actionscript3][] implementation.

SMILKit has three core components:

- Asset Handler Framework
- SMIL Parser and DOM Generator
- Timing and Rendering Engine

![SMILKit components](http://cl.ly/H6r/content)

Asset Handler Framework
=======================

Asset loading, rendering and manipulation takes place inside Handlers which are locked to there corresponding SMILMediaElement. Handlers are generic classes which can be created to handle a certain Asset type. Handlers are registered to protocols, mimetype / extensions and url regular expression.

SMIL Parser and DOM Generator
=============================

SMIL Parsing is left to the implementations, but they must guarantee that the SMIL 3.0 DOM behaves in a manner consistent across all implementations.

SMIL 3.0 DOM
------------

SMILKit uses a SMIL 3.0 DOM based on the W3C [DOM Level 2][] standard and the W3C Draft of [Boston DOM][]. The DOM becomes the main interface for controlling a SMILKit session, the document provides an API with methods to manipulate playback, loading and time resolution.

All relevant Engine functionality is presented through the DOM.  The DOM is an abstract representation of the SMIL document plus the computed properties of the Document, as informed by the other Engine components.  Changes made through the DOM are delegated to the appropriate Engine component, maintaining a clear separation of concerns.

Timing and Rendering Engine
===========================

The Timing and Rendering engine is responsible for keeping time synchronisation throughout SMILKit, it uses the Timing Graph as a resolved cache of timed elements. The Rendering Engine is able to paint the current active elements from the Timing Graph to SMILKit's canvas. The Rendering Engine is also responsible for the layout and position of elements on the canvas.

Timing Graph
------------

The Timing Graph provides a list of resolved SMILMediaElements and there corresponding time data. Any element placed in the Timing Graph must be fully resolved, this means child elements or dependences need to also be resolved before the element can be added to the list.

During every heartbeat SMILKit will iterate through the Timing Graph and populate the render tree with the current active elements.

Render Tree
-----------

The Render Tree provides a tree of elements that exist at the current point in time, the tree is responsible for controlling the content that exists on the Canvas (SMILKit's display stage). The tree is populated during every heartbeat by iterating through the Timing Graph, any new assets will be added to the Render Tree and the old ones removed. When the Render Tree is manipulated everything is re-painted to the Canvas, if the Render Tree isn't modified during a heartbeat the Canvas is left as it is.


Compiling SMILKit-AS3
=====================

Requires Adobe [Flex SDK][] 4+ and ANT.

Needs to have `FLEX_HOME` defined in your environment variables, should point to your Flex SDK. Define `FLEX_HEADLESS` as `true` when building on Linux headless servers (via [xVNC][]).

#### Full build, test and produce reports + docs

	ant build
	
#### Test

	ant test
	
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