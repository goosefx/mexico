local mexico = require "mexico"

--
-- Mixin: EventSource
--
-- 
--
local EventSource = {}

--
-- Used to fire an event
--
-- Parameters:
--  + event       [table]   : the event object.
--  + cancelable  [boolean] : (optional) Indicates a cancelable event
--
function EventSource:dispatchEvent(event, cancelable)
  mexico.Object.assert(self)
  -- check if we have any listener for the event
  if not self._events or not self._events[event.name] then return end
   -- iterate over all registered event listeners
  for i,listener in ipairs(self._events[event.name]) do
    -- invoke listener
    if type(listener) == "function" then
      listener(event) -- function
    else
      listener[event.name](listener, event) -- object
    end
    -- check if canceled
    if cancelable and event.cancel then return end
  end
end

--
-- Adds a listener to the object’s list of listeners. When the named event occurs, 
-- the listener will be invoked and be supplied with a table representing the event.
--
-- Parameters:
--  + eventName [string] : The name of the event to listen for.
--  + listener  [mixed]  : Event listeners are either functions or objects (a.k.a. table listeners).
--
function EventSource:addEventListener(eventName, listener)
  mexico.Object.assert(self)
  if not self._events then self._events = {} end
  if not self._events[eventName] then self._events[eventName] = {} end
  table.insert(self._events[eventName], listener)
end

--
-- Removes the specified listener from the object's list of listeners so that it no longer 
-- is notified of events corresponding to the specified event.
--
-- Parameters:
--  + eventName [string] : The name of the event whose corresponding listener should be removed from the list.
--  + listener  [mixed]  : The listener to remove from the list.
--
function EventSource:removeEventListener(eventName, listener)
  mexico.Object.assert(self)
  -- no events or specific event not found
  if not self._events or not self._events[eventName] then return end
  -- iterate over all registered event listeners
  for i,test in ipairs(self._events[eventName]) do
    if listener == test then
      table.remove(self._events[eventName], i)
      return
    end
  end
end

return EventSource
