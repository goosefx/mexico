local mexico = require "mexico"

--
-- GarbageCollector
--
-- Properties:
--
--  + performWithDelay [boolean] : Perform garbage collection with a 1 ms delay once per frame
--
local GarbageCollector = mexico.class(false) -- create a class without base (a root class)

function GarbageCollector:init()
  if self then
    self.performWithDelay = true                    -- delay collect garbage by default with a timer
    Runtime:addEventListener("memoryWarning", self) -- listen to memory warnings
  end  
end

--
-- Returns the amount of memory (KB) allocated by the Lua VM runtime.
--
function GarbageCollector:memoryUsed()
  return math.ceil(collectgarbage("count") + 0.5)
end

--
-- Returns the amount of allocated texture memory (KB).
--
function GarbageCollector:textureMemoryUsed()
  return math.ceil((system.getInfo("textureMemoryUsed") / 1000) + 0.5)
end

function GarbageCollector:timer(event)
  self:collectGarbage()
  self.timerHandle = nil
end

function GarbageCollector:memoryWarning()
  print("WARNING: received low memory warning from the system")
  self:collectGarbage()          -- collect garbage immediatly
  if self.performWithDelay then
    self:collect()               -- and once again with with delay
  end
end


function GarbageCollector:collectGarbage()
  collectgarbage("collect")
  print("INFO: " .. self:memoryUsed() .. " kb memory and " .. tostring(self:textureMemoryUsed()) .. " kb texture memory used after garbage collection")
end

function GarbageCollector:collect()
  if self and self.performWithDelay then
    if not self.timerHandle then
      self.timerHandle = timer.performWithDelay(1, self) 
    end
  else
    self:collectGarbage()
  end
end

-- GC is a singleton - so return an instance and not a class object
return GarbageCollector()


