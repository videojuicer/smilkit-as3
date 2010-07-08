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

The MIT License

Copyright (c) 2010 Videojuicer Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

### Xerces-J

Apache Xerces Java
Copyright 1999-2006 The Apache Software Foundation

This product includes software developed at
The Apache Software Foundation (http://www.apache.org/).

Portions of this software were originally based on the following:
  - software copyright (c) 1999, IBM Corporation., http://www.ibm.com.
  - software copyright (c) 1999, Sun Microsystems., http://www.sun.com.
  - voluntary contributions made by Paul Eng on behalf of the 
    Apache Software Foundation that were originally developed at iClick, Inc.,
    software copyright (c) 1999.
    
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

### Base64

Base64 - 1.1.0

Copyright (c) 2006 Steve Webster

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions: 

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[SMIL 3.0]: http://www.w3.org/TR/SMIL3/ "SMIL 3.0"
[Actionscript3]: http://en.wikipedia.org/wiki/ActionScript "Actionscript3"
[Flex SDK]: http://opensource.adobe.com/wiki/display/flexsdk/Flex+SDK "Flex SDK"
[DOM Level 2]: http://www.w3.org/TR/2000/REC-DOM-Level-2-Core-20001113/ "W3C DOM Level 2"
[Boston DOM]: http://www.w3.org/TR/smil-boston-dom/cover.html "Boston DOM"
[Xerces Java Parser]: http://xerces.apache.org/xerces-j/apiDocs/index.html "Xerces Java Parser"
[xVNC]: http://xvnc.sourceforge.net/ "xVNC"