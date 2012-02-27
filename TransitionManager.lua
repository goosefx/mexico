--------------------------------------------------------------------------------------------------------------------
local mexico = require "mexico"                                -- load the mexico framework                       --
--------------------------------------------------------------------------------------------------------------------
--                                                                                                                --
-- Class: TransitionManager                                                                                       --
--                                                                                                                --
-- Used to manage all transitions in a game scene. You can pause, resume and cancel all transitions at once.      --
--                                                                                                                --
-- Properties:                                                                                                    --
--  + isPaused [boolean] : (ReadOnly) Indicates whether all managed transitions are cureently paused or not.      --                                                                  --
--                         The value of this property is important if you add new transitions after a call to     --
--                         <TransitionManager:pauseAll>. If it is true, all newly added transitions are auto-     --
--                         matically paused.                                                                      --
--                                                                                                                --
-- Methods:                                                                                                       --
--  + to        ( target , params)                                                                                --
--  + from      ( target , params)                                                                                --
--  + cancel    ( id )                                                                                            --
--  + pause     ( id )                                                                                            --
--  + resume    ( id )                                                                                            --
--  + pauseAll  ( )                                                                                               --
--  + resumeAll ( )                                                                                               --
--  + cancelAll ( )                                                                                               --
--                                                                                                                --
--------------------------------------------------------------------------------------------------------------------
local TransitionManager = mexico.class(mexico.Object)                                                             --
--------------------------------------------------------------------------------------------------------------------
--                                                                                                                --
-- Constructor                                                                                                    --
--                                                                                                                --
-- Parameters:                                                                                                    --
--  + isPaused [boolean] : Initial manager state.                                                                 --
--                                                                                                                --
--------------------------------------------------------------------------------------------------------------------
function TransitionManager:init(isPaused)                      --                                                 --
  self.nextId      = 1                                         -- next item id                                    --
  self.items       = {}                                        -- container for transition items                  --
  self.isPaused    = isPaused                                  -- paused or not by default                        --
end                                                            --                                                 --
--------------------------------------------------------------------------------------------------------------------
--                                                                                                                --
-- (Internal) Used by <TransitionManager:to> and <TransitionManager:from> to track a corona transition.           --
--                                                                                                                --
--------------------------------------------------------------------------------------------------------------------
function TransitionManager:add(target, params)                 --                                                 --
  mexico.Object.assert(self)                                   -- test if self is not null and not disposed       --   
  local itemId   = self.nextId                                 -- next item id                                    --
  self.nextId    = itemId + 1                                  -- increate next id                                --
--------------------------------------------------------------------------------------------------------------------
  local item     = {                                           -- create transition state item                    --
    id           = itemId,                                     --   unique id                                     --
    state        = "added",                                    --   current transition state                      --
    target       = target,                                     --   transition target                             --
    params       = params,                                     --   transition parameters                         --
    original     = {                                           --   remember some original params                 -- 
      onComplete = params.onComplete,                          --     original on complete callback               --
      delay      = params.delay,                               --     original transition delay                   --
      time       = params.time,                                --     original transition time                    --
    },                                                         --                                                 --
--------------------------------------------------------------------------------------------------------------------
    to           = function(me)                                --   transition to wrapper                         --
      me.mode    = "to"                                        --     transition mode is to                       --
      me.started = system.getTimer()                           --     start time                                  --
      me.handle  = transition.to(me.target, me.params)         --     corona transition handle                    --
      me.state   = "running"                                   --     state is now running                        --
    end,                                                       --                                                 --
--------------------------------------------------------------------------------------------------------------------
    from         = function(me)                                --   transition from wrapper                       --
      me.mode    = "from"                                      --     transition mode is from                     --
      me.started = system.getTimer()                           --     start time                                  --
      me.handle  = transition.from(me.target, me.params)       --     corona transition handle                    --
      me.state   = "running"                                   --     state is now running                        --
    end,                                                       --                                                 --
--------------------------------------------------------------------------------------------------------------------
    prepare      = function(me, mode)                          --   prepare transition but not start it           --
      me.mode    = mode                                        --     the target transition mode                  --
      me.started = system.getTimer()                           --     set started time = paused time              --
      me.paused  = me.started                                  --                                                 --
      me.state   = "paused"                                    --     initial state is paused                     --
    end,                                                       --                                                 --
--------------------------------------------------------------------------------------------------------------------
    pause = function(me)                                       --                                                 --
      if (me.state == "running") then                          -- test if transation running (or sheduled)        --
        if me.handle then                                      --                                                 --
          transition.cancel(me.handle)                         --   cancel corona transition                      --
          me.handle = nil                                      --                                                 --
          me.paused = system.getTimer()                        --   paused since                                  --
          me.state  = "paused"                                 --   state is paused now                           --       
        end                                                    --                                                 --
      end                                                      --                                                 --
    end,                                                       --                                                 --
--------------------------------------------------------------------------------------------------------------------
    resume = function(me)                                      --                                                 --
      if (me.state == "paused") then                           -- test if transation is paused                    --
        local elapsed = me.paused - me.started                 --   elapsed time between started and paused       --
        if ((me.params.delay or 0) > elapsed) then             --   test if transition is still delayed           --
          me.params.delay = me.params.delay - elapsed          --     shorten delay time                          --
        else                                                   --   or it transition time must be cut             --
          me.params.time  = me.params.time - elapsed -         --     calculate left transition time              --
                              (me.params.delay or 0)           --                                                 --
          me.params.delay = 0                                  --     reset delay                                 --
        end                                                    --                                                 --
        me.paused         = 0                                  --   reset paused since time                       --
        if me.mode == "from" then                              --   restart either to or from transition          --
          me:from() else                                       --                                                 --
          me:to()                                              --                                                 --
        end                                                    --                                                 --
      end                                                      --                                                 --
    end,                                                       --                                                 --
--------------------------------------------------------------------------------------------------------------------
    cancel = function(me)                                      --                                                 --
      if (me.state == "running") then                          --   test if transation is running (or sheduled)   --
        if me.handle then                                      --                                                 --
          transition.cancel(me.handle)                         --     cancel corona transition                    --
        end                                                    --                                                 --
        me:restore()                                           --   restore transition to its original state      --                                 
        me:dispose()                                           --   dispose item since it is no longer of use     --
      end                                                      --                                                 --
    end,                                                       --                                                 --
--------------------------------------------------------------------------------------------------------------------
    restore = function(me)                                     --   Used to restore the transition into its       --
      me.params.onComplete   = me.original.onComplete          --   original state                                --
      me.params.delay        = me.original.delay               --                                                 --
      me.params.time         = me.original.time                --                                                 --
    end,                                                       --                                                 --
--------------------------------------------------------------------------------------------------------------------
    dispose = function(me)                                     --   Used to clean the item if it is no longer     --
      if me.original then                                      --   of use.                                       --
        me.original.onComplete = nil                           --                                                 --
        me.original            = nil                           --                                                 --
      end                                                      --                                                 --
      me.target                = nil                           --                                                 --
      me.params                = nil                           --                                                 --
      me.handle                = nil                           --                                                 --
    end,                                                       --                                                 --
  }                                                            --                                                 --
--------------------------------------------------------------------------------------------------------------------
  params.onComplete  = function() self:onComplete(itemId) end  -- change onComplete callback                      --
  self.items[itemId] = item                                    -- store item reference                            --
  return item                                                  -- return item                                     --
end                                                            --                                                 --
--------------------------------------------------------------------------------------------------------------------
--                                                                                                                --
-- (Internal) Called after a transition is complete.                                                              --
--                                                                                                                --
--------------------------------------------------------------------------------------------------------------------
function TransitionManager:onComplete(itemId)                  --                                                 --
  local item = self.items[itemId]                              -- get item by id                                  --
  if item then                                                 -- do we have an item?                             --
    local callback = item.original.onComplete                  --   original on complete callback                 --
    item:restore()                                             --   restore transition to its original state      --                                 
    item:dispose()                                             --   dispose item since it is no longer of use     --
    self.items[itemId] = nil                                   --   remove item from manager                      --
    item               = nil                                   --                                                 --
    if callback then callback() end                            --   invoke original on complete callback          --
  end                                                          --                                                 --
end                                                            --                                                 --
--------------------------------------------------------------------------------------------------------------------
--                                                                                                                --
-- Animates a display object's properties over time.                                                              --
--                                                                                                                --
-- Parameters:                                                                                                    --
--  + target [object] : A display object that will be the target of the transition.                               --
--  + params [table]  : A table that specifies the properties of the display object which will be animated.       --
--                                                                                                                --
-- Returns:                                                                                                       --
-- A unique id identifing the transition. This is NOT the handle returned by corona's transition.to.              --
--                                                                                                                --
--                                                                                                                --
-- See Corona SDK documentation (http://developer.anscamobile.com/node/2407) for more information.                --
--                                                                                                                --
--------------------------------------------------------------------------------------------------------------------
function TransitionManager:to(target, params)                  --                                                 --
  mexico.Object.assert(self)                                   -- test if self is not null and not disposed       --   
  local item = self:add(target, params)                        -- add transition to item collection               --
  if self.isPaused then item:prepare("to") else item:to() end  -- if manager is paused then do not start the      --
  return item.id                                               -- transition directly, instead just set the       --
end                                                            -- target transition mode                          --
--------------------------------------------------------------------------------------------------------------------
--                                                                                                                --
-- Similar to <TransitionManager:to> except the starting property values are specified in the function's          --
-- parameter table and the final values are the corresponding property values in target prior to the call.        --
--                                                                                                                --
-- Parameters:                                                                                                    --
--  + target [object] : A display object that will be the target of the transition.                               --
--  + params [table]  : A table that specifies the properties of the display object which will be animated.       --
--                                                                                                                --
-- Returns:                                                                                                       --
-- A unique id identifing the transition. This is NOT the handle returned by corona's transition.from.            --
--                                                                                                                --
-- Remarks:                                                                                                       --
-- Note that adding a from-transition to a paused transition manager my result in an unexpected behavior, since   --
-- the transition will be first applied to the target object then the manager will be resumed.                    --
--                                                                                                                --
-- See Corona SDK documentation (http://developer.anscamobile.com/node/2407) for more information.                --
--                                                                                                                --
--------------------------------------------------------------------------------------------------------------------
function TransitionManager:from(target, params)                --                                                 --
  mexico.Object.assert(self)                                   -- test if self is not null and not disposed       --   
  local item = self:add(target, params)                        -- add transition to item collection               --
  if self.isPaused then item:prepare("from") else              -- if manager is paused then do not start the      --
  item:from() end                                              --                                                 --
  return item.id                                               -- transition directly, instead just set the       --
end                                                            --                                                 --
--------------------------------------------------------------------------------------------------------------------
--                                                                                                                --
-- Cancel a single running or sheduled transition.                                                                --
--                                                                                                                --
-- Parameters:                                                                                                    --
--  + id [number] : The id assigned and returned by <TransitionManager:to> or <TransitionManager:from>.           --
--------------------------------------------------------------------------------------------------------------------
function TransitionManager:cancel(id)                          --                                                 --
  mexico.Object.assert(self)                                   -- test if self is not null and not disposed       --
  local item = self.items[id]                                  -- get item by id                                  --
  if (item) then                                               -- check if item is not null                       --
    item:cancel()                                              --   cancel item                                   --
    item = nil                                                 --                                                 --
    self.items[id] = nil                                       --   remove item from items collection             --
    mexico.gc:collect()                                        --   collect garbage next frame                    --
    return true                                                --   transition canceled                           --
  end                                                          --                                                 --
  return false                                                 -- failed but ok                                   --
end                                                            --                                                 --
--------------------------------------------------------------------------------------------------------------------
--                                                                                                                --
-- Pauses a single running or sheduled transition.                                                                --
--                                                                                                                --
-- Parameters:                                                                                                    --
--  + id [number] : The id assigned and returned by <TransitionManager:to> or <TransitionManager:from>.           --
--------------------------------------------------------------------------------------------------------------------
function TransitionManager:pause(id)                           --                                                 --
  mexico.Object.assert(self)                                   -- test if self is not null and not disposed       --
  local item = self.items[id]                                  -- get item by id                                  --
  if (item) then                                               -- check if item is not null                       --
    item:pause()                                               --   pause item                                    --
    return true                                                --   transition paused                             --
  end                                                          --                                                 --
  return false                                                 -- failed but ok                                   --
end                                                            --                                                 --
--------------------------------------------------------------------------------------------------------------------
--                                                                                                                --
-- Resumes a previously paused transition.                                                                        --
--                                                                                                                --
-- Parameters:                                                                                                    --
--  + id [number] : The id assigned and returned by <TransitionManager:to> or <TransitionManager:from>.           --
--------------------------------------------------------------------------------------------------------------------
function TransitionManager:resume(id)                          --                                                 --
  mexico.Object.assert(self)                                   -- test if self is not null and not disposed       --
  local item = self.items[id]                                  -- get item by id                                  --
  if (item) then                                               -- check if item is not null                       --
    item:resume()                                              --   resume item                                   --
    return true                                                --   transition paused                             --
  end                                                          --                                                 --
  return false                                                 -- failed but ok                                   --
end                                                            --                                                 --
--------------------------------------------------------------------------------------------------------------------
--                                                                                                                --
-- Cancel all running or sheduled transitions at once.                                                            --
--                                                                                                                --
--------------------------------------------------------------------------------------------------------------------
function TransitionManager:cancelAll()                         --                                                 --
  mexico.Object.assert(self)                                   -- test if self is not null and not disposed       --   
  print("Transitionmanager: cancelAll")                        --                                                 --
  for id,item in pairs(self.items) do                          -- iterate over all transition items               --
    item:cancel()                                              --   cancel the transition                         --
    item = nil                                                 --                                                 --
  end                                                          --                                                 --
  self.items = {}                                              -- reset items collection                          --
  mexico.gc:collect()                                          -- collect garbage next frame                      --
end                                                            --                                                 --
--------------------------------------------------------------------------------------------------------------------
--                                                                                                                --
-- Pauses all running or sheduled transitions at once.                                                            --
--                                                                                                                --
--------------------------------------------------------------------------------------------------------------------
function TransitionManager:pauseAll()                          --                                                 --
  mexico.Object.assert(self)                                   -- test if self is not null and not disposed       --   
  print("Transitionmanager: pauseAll")                         --                                                 --
  self.isPaused = true                                         -- will auto pause all further added transitions   --
  for id,item in pairs(self.items) do                          -- iterate over all transition items               --
    item:pause()                                               --   pause the transition                          --
  end                                                          --                                                 --
end                                                            --                                                 --
--------------------------------------------------------------------------------------------------------------------
--                                                                                                                --
-- Resumes all previously paused transitions at once.                                                             --
--                                                                                                                --
--------------------------------------------------------------------------------------------------------------------
function TransitionManager:resumeAll()                         --                                                 --
  mexico.Object.assert(self)                                   -- test if self is not null and not disposed       --   
  print("Transitionmanager: resumeAll")                        --                                                 --
  self.isPaused = false                                        --                                                 --
  for id,item in pairs(self.items) do                          -- iterate over all transition items               --
    item:resume()                                              --   resume the transition                         --
  end                                                          --                                                 --
end                                                            --                                                 --
--------------------------------------------------------------------------------------------------------------------
--                                                                                                                --
--                                                                                                                --
--                                                                                                                --
--------------------------------------------------------------------------------------------------------------------
function TransitionManager:dispose()                           --                                                 --
  mexico.Object.assert(self)                                   -- test if self is not null and not disposed       --   
  self:cancelAll()                                             -- cancel all transitions                          --
  self.items = nil                                             -- remove transition item collection               --
  mexico.Object.dispose(self)                                  -- base or super dispose call                      --
end                                                            --                                                 --
--------------------------------------------------------------------------------------------------------------------
return TransitionManager                                                                                          --
--------------------------------------------------------------------------------------------------------------------