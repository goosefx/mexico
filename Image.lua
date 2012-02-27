local mexico = require "mexico"

--
-- Mexico wrapper for a corona images.
--
local Image = mexico.class(mexico.DisplayObject)

--
-- Magic new function, since corona creates the object
-- and not we.
--
Image.new = function(styles) 
  if styles.left then
    return display.newImage(styles.filename, styles.left, styles.top, styles.isFullResolution or false) 
  else   
    return display.newImage(styles.filename, styles.isFullResolution or false) 
  end
end

--
--
--
function Image:init(styles)
  local styles = table.mexico.clone(styles)
  styles["filename"]         = nil
  styles["left"]             = nil
  styles["top"]              = nil
  styles["isFullResolution"] = nil
  mexico.DisplayObject.init(self, styles) 
end


return Image