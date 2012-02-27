local mexico = require "mexico"

--
-- Mexico wrapper for a corona images.
--
local ImageRect = mexico.class(mexico.DisplayObject)

--
-- Magic new function, since corona creates the object
-- and not we.
--
ImageRect.new = function(styles) 
  local w = styles.width or display.contentWidth
  local h = styles.height or display.contentHeight
  return display.newImageRect(styles.filename, w, h) 
end

--
--
--
function ImageRect:init(styles)
  local styles = table.mexico.clone(styles)
  styles["filename"] = nil
  styles["width"]    = nil
  styles["height"]   = nil
  mexico.DisplayObject.init(self, styles) 
end


return ImageRect