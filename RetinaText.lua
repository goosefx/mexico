local mexico = require "mexico"

--
-- Mexico wrapper for a corona retina text.
--
local RetinaText = mexico.class(mexico.DisplayObject)

--
-- Magic new function, since corona creates the object
-- and not we.
--
RetinaText.new = function(styles) 
  local l = styles.left or 0
  local t = styles.top or 0
  local w = styles.width
  local h = styles.height
  local f = styles.font or native.systemFont
  local s = styles.size or 20
  local x = styles.text
  
  if w then
    return display.newRetinaText(x, l, t, w, h, f, s)
  else
    return display.newRetinaText(x, l, t, f, s)
  end
end

--
-- Constructor
--
function RetinaText:init(styles)
  local styles = table.mexico.clone(styles)
  styles["text"]   = nil
  styles["left"]   = nil
  styles["top"]    = nil
  styles["width"]  = nil
  styles["height"] = nil
  styles["font"]   = nil
  styles["size"]   = nil
  mexico.DisplayObject.init(self, styles) 
end


return RetinaText