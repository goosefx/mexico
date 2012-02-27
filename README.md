# Mexico - Object Oriented Programming with [Corona SDK](http://www.anscamobile.com/corona/)

## Features

   - Class - use inheritance in your own project
   - Mixins - add common functionality to your objecs
   - Styles - create display objects css-a-like
   - Scene Director - easy to use, powerful and extensible
   - Garbage Collector - intelligent garbage collection
   - Display Objects - reusable functionality

## Getting Started

Using `mexico` is pretty easy. Clone the the latest `mexico` sources from github.

	$ cd my-project
	$ $ git clone git://github.com/goosefx/mexico mexico
  
#### Create or modify your `main.lua` file to look like this:

	-- load mexico framework
	local mexico = require "mexico.framework"
	-- run the application
	mexico.run()

#### Create a new file `app.lua` inside your project folder:

	-- load mexico framework (now without .framework)
	local mexico = require "mexico"
	
	-- Define your Application class
	local App = mexico.class(mexico.Application)
	
	-- Constructor
	function App:init()
		-- super init
    	mexico.Application.init(self)
    	-- hide status bar
    	self:setStatusBar("Hidden")
	end
  
	-- Called on application start
	function App:onStart(event)
		self.sceneDirector:pushScene("Splash")
	end
  
	-- return application instance
	return App()

Next we have to define our first scene.

	$ cd my-project
	mkdir scenes

#### Create a new file `Splash.lua` inside the new `scenes` folder

    local mexico = require "mexico"
    
    -- Class: Splash 
    local Splash = mexico.class(mexico.Scene)
    
    -- Called to load the scene
    function Splash:onLoad(event)
      self:newRect({ fillColor = {0,0,255} })
      self:newRetinaText({ text = 'loading...' })
    end
    
    -- return your class definition
    return Splash

That's it. You have created your first object-oriented corona/mexico application. 

## Object Oriented Programming

`mexico` comes with a lightweight `OOP` layer for `lua`. … 

### Classes

…

### Mixins

…

## Scene Director

…

## Garbage Collector

…

## Display Objects

…

# Examples

…

# Licence

(The MIT License)

Copyright (c) 2010,2012 Marcus Wilhelm <mwilhelm@me.com>

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.