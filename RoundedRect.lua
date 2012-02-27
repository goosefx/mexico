local mexico = require "mexico"

--
-- Mexico wrapper for a corona rounded rectangle.
--
local RoundedRect = mexico.class(mexico.DisplayObject)

--
-- Magic new function, since corona creates the object
-- and not we.
--
RoundedRect.new = function(styles) 
  local l = styles.left or 0
  local t = styles.top or 0
  local w = styles.width or display.contentWidth
  local h = styles.height or display.contentHeight
  local r = styles.cornerRadius or h / 2
  return display.newRoundedRect(l, t, w, h, r) 
end

--
-- Constructor
--
function RoundedRect:init(styles)
  local styles = table.mexico.clone(styles)
  styles["left"]         = nil
  styles["top"]          = nil
  styles["width"]        = nil
  styles["height"]       = nil
  styles["cornerRadius"] = nil
  mexico.DisplayObject.init(self, styles) 
end


return RoundedRect