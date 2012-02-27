--------------------------------------------------------------------------------------------------------------------
local mexico = require "mexico"                                -- load the mexico framework                       --
--------------------------------------------------------------------------------------------------------------------
--                                                                                                                --
-- Class: SceneDirector                                                                                           --
--                                                                                                                --
-- Used to manage game scenes in an intuitive and comfortable way. Push, pop and replace scenes easily with pre-  --
-- defined or custom transition effects.                                                                          --
--                                                                                                                --
-- Properties:                                                                                                    --
--  + transitionTime   [number]  : The time of a scene transition. Default is 300 ms.                             --
--  + clearSceneOnPush [boolean] : If true the scene director will call                                           --
--                                 scene's clear function after it leaves the stage with                          --
--                                 a push. Default is false.                                                      --
--                                                                                                                --
-- Methods:                                                                                                       --
--  + pushScene(scene [,effect])                                                                                  --
--  + popScene([effect])                                                                                          --
--  + replaceScene(scene [,effect])                                                                               --
--                                                                                                                --
--------------------------------------------------------------------------------------------------------------------
local SceneDirector = mexico.class(mexico.View, mexico.EventSource)                                               --
--------------------------------------------------------------------------------------------------------------------
--                                                                                                                --
-- Constructor                                                                                                    --
--                                                                                                                --
--------------------------------------------------------------------------------------------------------------------
function SceneDirector:init()                                  --                                                 --
  mexico.View.init(self)                                       -- base or super call                              --
                                                               --                                                 --
  self.transitionTime   = 300                                  -- default view transition time                    --
  self.clearSceneOnPush = false                                -- call clean on last scene after a new scene was  --
                                                               -- pushed                                          --
  self.transitions      = mexico.Queue()                       -- queue of  waiting or running transitions        --
  self.scenes           = mexico.Stack()                       -- scene stack                                     --
end                                                            --                                                 --
--------------------------------------------------------------------------------------------------------------------
--                                                                                                                --
-- Push a scene on stage using the given effect (see <SceneDirectorEffects> for possible values)                  --
--                                                                                                                --
-- Parameters:                                                                                                    --
--  + scene   [strong or table]    : The scene to push on stage.                                                  --
--  + effect  [string or function] : The transition effect. Note if you push your very first scene                --
--                                   you should not specify an effect. Default is <SceneDirectorEffects.None>.    --
--                                                                                                                --
--------------------------------------------------------------------------------------------------------------------
function SceneDirector:pushScene(scene, effect)                --                                                 --
  mexico.Object.assert(self)                                   -- assert object is not null or disposed           --
  local me = self                                              --                                                 --
  self.transitions:enqueue(function()                          -- enqueue function to execute the push operation  --
    if type(scene) == "string" then                            -- if scene is given by name                       --
      scene = mexico.Scene.fromFile(scene)                     --   load the next scene from a file in the        --
    end                                                        --   application's scene directory                 --
    me.scenes:push(scene)                                      -- add scene to local scene stack (on top)         --
    me:beginTransitionTo(scene, effect, "push")                -- begin the transition to the next scene          --
  end)                                                         --                                                 --
  if self.transitions.size == 1 then                           -- if the enqueued transition function is the      --
    local firstTransition = self.transitions:peek()            -- first in the queue, execute it                  --
    firstTransition()                                          --                                                 --
  end                                                          --                                                 --
end                                                            --                                                 --
--------------------------------------------------------------------------------------------------------------------
--                                                                                                                --
-- Pop the current top most scene off stage using the given effect.                                               --
-- (see <SceneDirectorEffects> for possible values)                                                               --
--                                                                                                                --
-- Parameters:                                                                                                    --
--  + effect  [string or function] : The transition effect. Default is <SceneDirectorEffects.None>.               --
--                                                                                                                --
--------------------------------------------------------------------------------------------------------------------
function SceneDirector:popScene(effect)                        --                                                 --
  mexico.Object.assert(self)                                   -- assert object is not null or disposed           --
  local me = self                                              --                                                 --
  self.transitions:enqueue(function()                          -- enqueue function to execute the pop operation   --
    local scene = self.scenes:pop()                            -- remove top most scene from scene stack          --
    self:beginTransitionTo(self.scenes:peek(), effect, "pop")  -- begin the transition to the previous scene      --
  end)                                                         --                                                 --
  if self.transitions.size == 1 then                           -- if the enqueued transition function is the      --
    print("SceneDirector: perform first transition in queue")  -- first in the queue, execute it                  --
    local firstTransition = self.transitions:peek()            --                                                 --
    firstTransition()                                          --                                                 --
  end                                                          --                                                 --
end                                                            --                                                 --
--------------------------------------------------------------------------------------------------------------------
--                                                                                                                --
-- Replaces the current scene using the given effect (see <SceneDirectorEffects> for possible values)             --
--                                                                                                                --
-- Parameters:                                                                                                    --
--  + scene   [strong or table]    : The scene which will replace the current one.                                --
--  + effect  [string or function] : The transition effect. Default is <SceneDirectorEffects.None>.               --
--                                                                                                                --
--------------------------------------------------------------------------------------------------------------------
function SceneDirector:replaceScene(scene, effect)             --                                                 --
  mexico.Object.assert(self)                                   --                                                 --
  local me = self                                              --                                                 --
                                                               --                                                 --
  self.transitions:enqueue(function()                          --                                                 --
    -- pop old scene                                           --                                                 --
    local oldScene = me.scenes:pop()                           --                                                 --
    -- load new scene                                          --                                                 --
    if type(scene) == "string" then                            --                                                 --
      scene = mexico.Scene.fromFile(scene)                     --                                                 --
    end                                                        --                                                 --
    -- push new scene                                          --                                                 --
    me.scenes:push(scene)                                      --                                                 --
    -- animate transition to next scene                        --                                                 --
    me:beginTransitionTo(scene, effect, "replace")             --                                                 --
  end)                                                         --                                                 --
                                                               --                                                 --
  if self.transitions.size == 1 then                           --                                                 --
    print("SceneDirector: perform first transition in queue")  --                                                 --
    local firstTransition = self.transitions:peek()            --                                                 --
    firstTransition()                                          --                                                 --
  end                                                          --                                                 --
end                                                            --                                                 --
--------------------------------------------------------------------------------------------------------------------

--
-- Callback that is invoked every time a scene transition is complete. 
--
function SceneDirector:onTransitionComplete(event)
  mexico.Object.assert(self)
  
  self.currentScene = event.to -- set new current view
  
  -- transition completed, so phase has ended
  event.phase = "ended" 
  
  -- last scene has left the stage
  if event.from then
    event.from:leave(event)
    event.from.director = nil
  end
 
  -- if a last view/scene exists, perform different task
  -- dependant on the action (push, pop or replace)
  
  if (event.from) then
    if event.action == "push" then
      event.from:hide() 
      if self.clearSceneOnPush and event.from.isLoaded then
        event.from:clear() 
      end
    else -- pop / replace
      event.from:dispose()
      event.from = nil
    end
  end
  
  -- next scene has entered the stage
  event.to:enter(event)
  
  -- fire 'transition' event 'ended'
  event.name = "transition"
  self:dispatchEvent(event)
  
  print("SceneDirector: transition to " .. event.to.name .. " ended")
  
  -- remove current completed transition from queue
  self.transitions:dequeue()
  
  -- collect garbage
	mexico.gc:collect()
  
  -- does we have a waiting transition?
  if self.transitions.size > 0 then
    print("SceneDirector: perform next transition")
    local nextTransition = self.transitions:peek()
    nextTransition()
  end
end

--
-- Begins a scene transition.
--
function SceneDirector:beginTransitionTo(scene, effect, action)
  mexico.Object.assert(self)
  
  local me = self
  
  print("SceneDirector: transition to " .. scene.name .. " began")
  
  if not effect then
    effect = mexico.SceneDirectorEffects.None
  elseif type(effect) == "string" then
    effect = mexico.SceneDirectorEffects[effect]
  end  
  
  assert(effect and type(effect) == "function", "Scene transition effect is null or invalid")
  
  local event      = {}
  event.target     = me
  event.name       = "transition"
  event.phase      = "began"
  event.delay      = 0
  event.time       = me.transitionTime
  event.from       = me.currentScene
  event.to         = scene
  event.action     = action
  event.onComplete = function() 
    me:onTransitionComplete(event) 
  end
  
  -- fire 'transition' event
  me:dispatchEvent(event)
  
  -- last scene will leave the stage
  if event.from then
    event.from:leave(event)
  end

  -- wrap effect for possible delay perform    
  local func = function()
    -- next scene will enter the stage
    event.to:show(self)
    event.to.director = self
    event.to:enter(event)
    effect(event)
  end
  
  -- perform effect (optional with delay)
  if event.delay > 0 then
    print("SceneDirector: perform transition effect with delay " .. tostring(event.delay))
    timer.performWithDelay(event.delay, func)
  else
    func()
  end
end

return SceneDirector