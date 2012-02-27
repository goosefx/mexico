local mexico = require "mexico"

--
-- Class: Scene
--
-- Properties:
--  + startBeforeEnter  [boolean] : Indicates to call start before scene will enter the stage. Default is true.
--  + resumeAfterEnter  [boolean] : Indicates to call resume after scene has entered the stage. Default is false.
--  + pauseBeforeLeave  [boolean] : Indicates to call pause before scene leaves the stage. Default is false.
--  + stopAfterLeave    [boolean] : Indicates to call stop after scene has left the stage. Default is true.
--  + isPaused          [boolean] : Indicates whether the scene is paused or not.
--  + isOnStage         [boolean] : Indicates whether the scene is currently on stage or not.                
-- Methods:
--
--
local Scene = mexico.class(mexico.View, mexico.EventSource)

--
-- Used to load and instanciate a scene class from the application's 
-- scene folder ('scenes/<name>').
--
Scene.fromFile = function(name, ...)
  local SceneClass = require ("scenes." .. name)
  if not SceneClass then error("Failed to load scene from " .. tostring(name) .. ".") end
  return SceneClass(name, ...)
end

--
-- Constructor
--
-- Creates a hidden display group for the scene.
--
function Scene:init(name)
  mexico.View.init(self)
  
  self.name             = name
  self.startBeforeEnter = true
  self.resumeAfterEnter = false
  self.pauseBeforeLeave = false
  self.stopAfterLeave   = true
  self.isStarted        = false
  self.isPaused         = false
  self.transitions      = mexico.TransitionManager(true)
end

--
-- Load the scene.
--
function Scene:clear()
  mexico.Object.assert(self)
  self:stop() -- always stop scene before clear
  mexico.View.clear(self) -- base or super call
  
end

--
-- Clear the scene.
--
function Scene:clear()
  mexico.Object.assert(self)
  self:stop() -- always stop scene before clear
  mexico.View.clear(self) -- base or super call
  
end

--
-- Start the scene.
--
function Scene:start()
  mexico.Object.assert(self)
  -- already started?
  if self.isStarted then 
    self:Stop() -- stop the scene first
  elseif self.isPaused then
    return false -- start not possible because scene is paused
  end
  -- create event object
  local event = {
    name      = "start",
    target    = self,
    phase     = "began",
  }
  -- dispatch event
  print(self:toString() .. ": start " .. event.phase)
  self:onStart(event)
  -- start all transitions
  self.transitions:resumeAll();
  -- dispatch event again
  event.phase = "ended"
  print(self:toString() .. ": start " .. event.phase)
  self:onStart(event)
  -- scene is started
  self.isStarted = true
  return true
end

--
-- Stop the scene.
--
function Scene:stop()
  mexico.Object.assert(self)
  -- resumable?
  if not self.isStarted then 
    return false 
  end
  -- create event object
  local event = {
    name      = "stop",
    target    = self,
    phase     = "began",
  }
  -- dispatch event
  print(self:toString() .. ": stop " .. event.phase)
  self:onResume(event)
  -- resume all transitions
  self.transitions:cancelAll();
  -- dispatch event again
  event.phase = "ended"
  print(self:toString() .. ": stop " .. event.phase)
  self:onStop(event)
  -- scene stopped
  self.isStarted = false
  self.isPaused  = false
  return true
end

--
-- Pause the scene.
--
function Scene:pause()
  mexico.Object.assert(self)
  -- already paused?
  if self.isPaused then return false end
  -- create event object
  local event = {
    name      = "pause",
    target    = self,
    phase     = "began",
  }
  -- dispatch event
  print(self:toString() .. ": pause " .. event.phase)
  self:onPause(event)
  -- pause all transitions
  self.transitions:pauseAll();
  -- dispatch event again
  event.phase = "ended"
  print(self:toString() .. ": pause " .. event.phase)
  self:onPause(event)
  -- scene paused
  self.isPaused = true
  return true
end

--
-- Resume the scene.
--
function Scene:resume()
  mexico.Object.assert(self)
  -- resumable?
  if not self.isPaused then return false end
  -- create event object
  local event = {
    name      = "resume",
    target    = self,
    phase     = "began",
  }
  -- dispatch event
  print(self:toString() .. ": resume " .. event.phase)
  self:onResume(event)
  -- resume all transitions
  self.transitions:resumeAll();
  -- dispatch event again
  event.phase = "ended"
  print(self:toString() .. ": resume " .. event.phase)
  self:onResume(event)
  -- scene resumed
  self.isPaused = false
  return true
end

--
-- IMPORTANT !!! DO NOT call or override this method !!! 
--
-- Called by <SceneDirector> before and after a scene will enter or has been entered the stage.
--
function Scene:enter(event)
  assert(event)
  mexico.Object.assert(self)
  -- update event object
  event.name   = "enter"
  event.target = self
  if (event.phase == "began") then
    print(self:toString() .. ": enter " .. event.phase)
    self:onEnter(event)
  end
  if (self.startBeforeEnter) and (event.phase == "began") and (not self.isStarted) then
    self:start() -- start scene if not already started
    if (self.resumeAfterEnter) then
      self:pause() -- immediatly pause if we must resume after enter
    end
  elseif (self.resumeAfterEnter) and (event.phase == "ended") and (self.isPaused) then
    self:resume() -- resume after enter if scene is paused
  end
  if (event.phase == "ended") then
    print(self:toString() .. ": enter " .. event.phase)
    self:onEnter(event)
  end
end

--
-- IMPORTANT !!! DO NOT call or override this method !!! 
--
-- Called by <SceneDirector> before and after a scene will leave or has been left the stage.
--
function Scene:leave(event)
  assert(event)
  mexico.Object.assert(self)
  -- update event object
  event.name   = "leave"
  event.target = self
  if (event.phase == "began") then
    print(self:toString() .. ": leave " .. event.phase)
    self:onLeave(event)
  end
  if (self.pauseBeforeLeave) and (event.phase == "began") and (self.isStarted) and (not self.isPaused) then
    self:pause()
  elseif (self.stopAfterLeave) and (event.phase == "ended") and (self.isStarted) then
    self:stop()
  end
  if (event.phase == "ended") then
    print(self:toString() .. ": leave " .. event.phase)
    self:onLeave(event)
  end
end

--
-- Callback that is invoked every time the scene will enter or has entered the stage. 
--
function Scene:onEnter(event)
  self:dispatchEvent(event)
end

--
-- Callback that is invoked every time the scene will leave or has left the stage. 
--
function Scene:onLeave(event)
  self:dispatchEvent(event)
end

--
-- Callback that is invoked it the scene will start or has been started. 
--
function Scene:onStart(event)
  self:dispatchEvent(event)
end

--
-- Callback that is invoked if the scene will stop or has been stopped. 
--
function Scene:onStop(event)
  self:dispatchEvent(event)
end

--
-- Callback that is invoked it the scene will pause or has been paused. 
--
function Scene:onPause(event)
  self:dispatchEvent(event)
end

--
-- Callback that is invoked if the scene will resume or has been resumed. 
--
function Scene:onResume(event)
  self:dispatchEvent(event)
end

--
-- Returns a string representation of the scene (Scene <id>).
--
function Scene:toString()
  mexico.Object.assert(self)
  return "Scene " .. (self.name or "Unknown");
end

return Scene


