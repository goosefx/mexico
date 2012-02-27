local mexico = require "mexico"

--
-- Mexico wrapper for a corona rectangle.
--
local Rect = mexico.class(mexico.DisplayObject)

--
-- Magic new function, since corona creates the object
-- and not we.
--
Rect.new = function(styles) 
  local l = styles.left or 0
  local t = styles.top or 0
  local w = styles.width or display.contentWidth
  local h = styles.height or display.contentHeight
  return display.newRect(l, t, w, h) 
end

--
-- Constructor
--
function Rect:init(styles)
  local styles = table.mexico.clone(styles)
  styles["left"]   = nil
  styles["top"]    = nil
  styles["width"]  = nil
  styles["height"] = nil
  mexico.DisplayObject.init(self, styles) 
end


return Rect