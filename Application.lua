local mexico = require "mexico"

--
-- Class: App
--
local Application = mexico.class(mexico.Object)

--
-- Constructor
--
function Application:init()
  -- create main, background and display layer
  self.rootLayer       = mexico.Group()
  self.backgroundLayer = self.rootLayer:newGroup()
  -- init scene director
  self.sceneDirector = mexico.SceneDirector()
  self.sceneDirector:show(self.mainLayer)    
  -- listen to system events
  Runtime:addEventListener("system", self)
  -- register app
  mexico.app = self
end

--
-- Hides or changes the appearance of the status bar.
--
-- Parameters:
-- + mode [string] : One of the following values:
--                   Hidden, Default, Translucent, Dark
--
function Application:setStatusBar(mode)
  display.setStatusBar(display[mode .. "StatusBar"])
end

function Application:onStart(event) 
end

function Application:onExit(event) 
end

function Application:onSuspend(event) 
end

function Application:onResume(event) 
end

function Application:system(event)
    if     event.type == "applicationStart"   then self:onStart   ({ source = self, name = "start"   }) 
    elseif event.type == "applicationExit"    then self:onExit    ({ source = self, name = "exit"    }) 
    elseif event.type == "applicationSuspend" then self:onSuspend ({ source = self, name = "suspend" }) 
    elseif event.type == "applicationResume"  then self:onResume  ({ source = self, name = "resume"  }) 
    end
end

function Application:dispose()
  mexico.Object.assert(self)
  
  mexico.app         = nil
  self.sceneDirector = self.sceneDirector:dispose()
  self.display       = self.display.dispose()
  self.background    = self.background.dispose()
  self.main          = self.main.dispose()
end


return Application
