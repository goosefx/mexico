--------------------------------------------------------------------------------------------------------------------
--                                                                                                                --
-- Mexico Framework for Corona SDK (http://www.coronasdk.com)                                                     --
--                                                                                                                --
--  + Author : Marcus Wilhelm <marcus@gooseflesh.de>                                                              --
--  + Url    : http://www.gooseflesh.de/mexico                                                                    --
--  + License: CC by 3.0 (http://creativecommons.org/licenses/by/3.0/)                                            --
--                                                                                                                --
--------------------------------------------------------------------------------------------------------------------
local mexico = require "mexico"                                -- load the mexico framework                       --
--------------------------------------------------------------------------------------------------------------------
--                                                                                                                --
-- Class: Group (extended)                                                                                        --
--                                                                                                                --
--------------------------------------------------------------------------------------------------------------------
-- Extensions to corona display groups.                                                                           --
--------------------------------------------------------------------------------------------------------------------
local Group = mexico.class(mexico.DisplayObject, mexico.DisplayFactory)                                           --
--------------------------------------------------------------------------------------------------------------------
Group.new = function(styles)                                   -- magic new function, since corona creates        --
  return display.newGroup()                                    -- groups and not we                               --
end                                                            --                                                 --
--------------------------------------------------------------------------------------------------------------------
--                                                                                                                --
-- Constructor                                                                                                    --
--                                                                                                                --
-- Parameters:                                                                                                    --
--  + styles [table] : A key value collection to initialize the group. Note that you can pass all corona group    --
--                     properties even those only changable with set methods (like referencePoint).               --
--                                                                                                                --
--------------------------------------------------------------------------------------------------------------------
-- Corona has problems if you change the reference point of an empty group.                                       --
-- That's why we add a dummy rectangle to the newly created group if a caller                                     --
-- tries to change the reference point in the constructor.                                                        --
--------------------------------------------------------------------------------------------------------------------
function Group:init(styles)                                                                                       --
--------------------------------------------------------------------------------------------------------------------
  local dummy                                                  -- reference for the dummy rect required below     --
  if styles and styles.referencePoint then                     -- if a caller tries to change the reference point --
    dummy    = self:newRect({                                  -- we create a dummy rectangle with the expected   --
      width  = styles.width or display.contentWidth,           -- size of the group to force group initialization --
      height = styles.height or display.contentHeight          --                                                 --
    })                                                         --                                                 --
  end                                                          --                                                 --
  mexico.DisplayObject.init(self, styles)                      -- Call base or super constructor                  --
  if dummy then                                                -- if we have created a dummy rectangle            --
    dummy:removeSelf()                                         -- remove it now                                   --
    dummy = nil                                                --                                                 --
  end                                                          --                                                 --
end                                                            --                                                 --
--------------------------------------------------------------------------------------------------------------------
return Group                                                   -- return the Group class information              --
--------------------------------------------------------------------------------------------------------------------
