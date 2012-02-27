local mexico = require "mexico"

--
-- Class: Button
--
-- Properties:
-- Methods:
--
local Button = mexico.class(mexico.Group)

--
-- Constructor
--
-- Creates a hidden empty view.
--
function Button:init(styles)
  local l   = styles.left           or styles.x or 40
  local t   = styles.top            or styles.y or  0
  local rp  = styles.referencePoint or "TopLeft"
  local w   = styles.width          or 240
  local h   = styles.height         or  50
  
  mexico.Group.init(self, { 
    x              = l,
    y              = t,
    width          = w,
    height         = h,
    referencePoint = rp,
    id             = styles.id,
    name           = styles.name,
    tag            = styles.tag
  })
  
  local bgi = styles.backgroundImage or nil

  if type(bgi) == "string" then
    -- create background layer
    self:newImageRect( { filename = bgi, x = 0, y = 0, width = w, height = h, referencePoint = "TopLeft" } )
  elseif type(bgi) == "table" then
    self:insert(bgi)
  else
    local r   = styles.cornerRadius    or  25
    local bgc = styles.backgroundColor or {255,255,255}
    local bot = styles.borderThickness or   4
    local boc = styles.borderColor     or { 80, 80, 80}
    
    if (r > 0) then
      -- create background layer
      self:newRoundedRect( { top = 0, left = 0, width =  w, height =  h, cornerRadius = r, fillColor = bgc })
      if (bot > 0) then
        self:newRoundedRect( { top = -bot, left = -bot, width = (w + 2*bot), height = (h + 2*bot), cornerRadius = r + bot, fillColor = boc })
      end
    else
      self:newRect( { top = 0, left = 0, width = w, height =  h, fillColor = bgc })
      if (bot >  0) then
         self:newRect( { top = -bot, left = -bot, width = (w + 2*bot), height = (h + 2*bot), fillColor = boc })
      end
    end
  end
      
  -- create text layer
  local txt = styles.text         or "Button"
  local txc = styles.textColor    or {  0,  0,  0}
  local txe = styles.embossedText or false
  local txf = styles.font
  local txs = styles.size
  local txa = styles.textAlign    or "Center"
  local txx = (w/2)
  local txr = "Center"
    
  if (txa == "Left") then
    txx = 5  
    txr = "CenterLeft"
  elseif (txa == "Right") then
    txx = w - 5
    txr = "CenterRight"
  end

  if txe then
    self._text = self:newEmbossedText( { text = txt, referencePoint = txr, x = txx, y = (h/2), textColor = txc, font = txf, size = txs } )
  else
    self._text = self:newRetinaText(   { text = txt, referencePoint = txr, x = txx, y = (h/2), textColor = txc, font = txf, size = txs } )
  end
      
  -- touch listener
  if styles.touch then
    self:addEventListener("touch", styles.touch)
  end
  
end

function Button:setText(text)
  if self._text then
    self._text:setText(text)
  end
end

function Button:dispatchEvent(event)
  if event.name == "touch" then
    self:setReferencePoint("Center")
    if event.phase == "began" then
      transition.to(self, { time = 100, xScale = 0.95, yScale = 0.95 } )
    elseif event.phase == "ended" then
      transition.to(self, { time = 100, xScale = 1.0 , yScale = 1.0  } )
      event.target = self
      self:original_dispatchEvent(event)
    end
  end      
end

return Button


