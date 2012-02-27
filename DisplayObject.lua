local mexico = require "mexico"

--
-- Base Clas for a Corona Display Object
--
-- Properties:
--
--
-- Styles:
--  + referencePoint [string] : Center, TopLeft, TopCenter, TopRight, CenterRight
--                              BottomRight, BottomCenter, BottomLeft, CenterLeft
--
local DisplayObject = mexico.class(mexico.Object)

--
-- Style Setter 
--
DisplayObject.setter = {
  color = function(obj, value)
    obj:setColor(unpack(value))
  end,
  strokeColor = function(obj, value)
    obj:setStrokeColor(unpack(value))
  end,
  fillColor = function(obj, value)
    local t = type(value)
    if t == "table" then
      local n = #value
      if n > 0 then
        if type(value[1]) == "table" then
          -- value is gradient
          obj:setFillColor(value)
        else
          -- value is color rgb(a)
          obj:setFillColor(unpack(value))
        end
      end
    else
      obj:setFillColor(value)
    end
  end,
  textColor = function(obj, value)
    local t = type(value)
    if t == "table" then
      local n = #value
      if n > 0 then
        if type(value[1]) == "table" then
          -- value is gradient
          obj:setTextColor(value)
        else
          -- value is color rgb(a)
          obj:setTextColor(unpack(value))
        end
      end
    else
      obj:setTextColor(value)
    end
  end,
  referencePoint = function(obj, value)
    obj:setReferencePoint(value)
  end,
}

--
--
--
function DisplayObject:init(styles)
  mexico.Object.init(self)
  self:setStyles(styles)  
end

function DisplayObject:setReferencePoint(value)
    self:original_setReferencePoint(display[value .. "ReferencePoint"])
end

--
-- Overridden Corona insert method. Will return the added object after insert.
--
function DisplayObject:insert(obj)
    self:original_insert(obj)
    return obj
end


--
--
--
function DisplayObject:setStyles(styles)
  mexico.Object.assert(self)
  if type(styles) ~= "table" then return end
  -- first change reference point if requested
  if styles.referencePoint then 
    DisplayObject.setter.referencePoint(self, styles.referencePoint) 
    styles.referencePoint = nil
  end
  
  for k,v in pairs(styles) do
    -- does a setter exist
    local setter = DisplayObject.setter[k]
    if setter then
      setter(self, v)
    else
      self[k] = v
    end
  end
end

--
--
--
function DisplayObject:dispose(freeMem)
  mexico.Object.assert(self)
  self:removeSelf()
  
  -- If we should free some memory after the display object
  -- is removed
  if freeMem then
    -- GarbageCollector is a singleton
    local GC = require "mexico.GarbageCollector"
    -- will call collectgarbage("collect") either directly or
    -- with a 1ms delay (default) - see GarbageCollector.lua for
    -- more information
    GC:collect()
  end
end

return DisplayObject