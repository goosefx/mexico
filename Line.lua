local mexico = require "mexico"

--
-- Mexico wrapper for a corona line.
--
local Line = mexico.class(mexico.DisplayObject)

--
-- Magic new function, since corona creates the object
-- and not we.
--
Line.new = function(styles) 
  return display.newLine(styles.x1, styles.y1, styles.x2, styles.y2) 
end

--
-- Constructor
--
function Line:init(styles)
  local styles = table.mexico.clone(styles)
  styles["x1"] = nil
  styles["x2"] = nil
  styles["y1"] = nil
  styles["y2"] = nil
  mexico.DisplayObject.init(self, styles) 
end


return Line