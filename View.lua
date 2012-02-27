local mexico = require "mexico"

--
-- Class: View
--
-- Properties:
--  + isLoaded    [boolean] : Indicates if the view is loaded (view's load function was called). 
--                            Default is false.
--  + clearOnHide [boolean] : Indicates to auto call view's clear function if it's hide function 
--                            is called. Default is false.
--
--
-- Methods:
--  + show([parent]) 
--  + hide()
--  + load()
--  + clear()
--  - onLoad()
--
local View = mexico.class(mexico.Group)

-- static hidden scenes group
local hiddenViews     = display.newGroup()
hiddenViews.x         = display.contentWidth
hiddenViews.isVisible = false

--
-- Constructor
--
-- Creates a hidden empty view.
--
function View:init(styles)
  mexico.Group.init(self, styles)
  self:hide()
end

--
-- Show the view.
--
-- Parameters:
--  + parent [table] : The parent display group. Default is the root group for all display objects.
--
function View:show(parent)
  mexico.Object.assert(self)
  if not self.isLoaded then self:load() end
  if parent then
      parent:insert(self)                  
  else
    display.getCurrentStage():insert(self)
  end
end

--
-- Load the view.
--
function View:load()
  mexico.Object.assert(self)
  self:onLoad({source = self, name = "load"})
  self.isLoaded = true
end

--
-- Load the view.
--
function View:onLoad(event)
end

--
-- Clear the view (removes all display objects).
--
function View:clear()
  mexico.Object.assert(self)
  if self.numChildren then
    while self.numChildren > 0 do
      local child = self[self.numChildren]
      if type(child.clear) == "function" then
        child:clear()
      end
      child:removeSelf()
      child = nil
    end
  end
  self.isLoaded = false
end

--
-- Hide the view (move it to the hidden views layer).
--
function View:hide()
  mexico.Object.assert(self)
  
  -- hide view's display group
  hiddenViews:insert(self)   
  
  if self.clearOnHide and self.isLoaded then 
    self:clear() 
  end
end

--
-- Prepare the view for garbage collection
--
function View:dispose()
  if self then
    self:clear()
    self:removeSelf()
  end
  mexico.Object.dispose(self)
end

return View


