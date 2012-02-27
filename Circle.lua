local mexico = require "mexico"

--
-- Mexico wrapper for a corona circle.
--
local Circle = mexico.class(mexico.DisplayObject)

--
-- Magic new function, since corona creates the object
-- and not we.
--
Circle.new = function(styles) 
  return display.newCircle(styles.x or 0, styles.y or 0, styles.radius) 
end

--
-- Constructor
--
function Circle:init(styles)
  local styles = table.mexico.clone(styles)
  styles["radius"]  = nil
  mexico.DisplayObject.init(self, styles) 
end


return Circle