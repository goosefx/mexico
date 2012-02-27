local mexico = require "mexico"

--
-- Mexico wrapper for a corona text.
--
local Text = mexico.class(mexico.DisplayObject)

--
-- Magic new function, since corona creates the object
-- and not we.
--
Text.new = function(styles) 
  return display.newText(styles.text, styles.left or 0, styles.top or 0, styles.font or native.systemFont, styles.size or 14) 
end

--
-- Constructor
--
function Text:init(styles)
  local styles = table.mexico.clone(styles)
  styles["text"]   = nil
  styles["left"]   = nil
  styles["top"]    = nil
  styles["font"]   = nil
  styles["size"]   = nil
  mexico.DisplayObject.init(self, styles) 
end

return Text