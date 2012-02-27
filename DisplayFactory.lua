local mexico = require "mexico"

--
-- Mexico wrapper for a corona display factory functions.
--
local DisplayFactory = {}

function DisplayFactory:newGroup(styles)
  local group = mexico.Group(styles)
  if self then self:insert(group) end
  return group
end

function DisplayFactory:newRect(styles)
  local rect = mexico.Rect(styles)
  if self then self:insert(rect) end
  return rect
end

function DisplayFactory:newRoundedRect(styles)
  local roundedRect = mexico.RoundedRect(styles)
  if self then self:insert(roundedRect) end
  return roundedRect
end

function DisplayFactory:newCircle(styles)
  local circle = mexico.Circle(styles)
  if self then self:insert(circle) end
  return circle
end

function DisplayFactory:newLine(styles)
  local line = mexico.Line(styles)
  if self then self:insert(line) end
  return line
end

function DisplayFactory:newImage(styles)
  local image = mexico.Image(styles)
  if self then self:insert(image) end
  return image
end

function DisplayFactory:newImageRect(styles)
  local imageRect = mexico.ImageRect(styles)
  if self then self:insert(imageRect) end
  return imageRect
end

function DisplayFactory:newText(styles)
  local text = mexico.Text(styles)
  if self then self:insert(text) end
  return text
end

function DisplayFactory:newRetinaText(styles)
  local retinaText = mexico.RetinaText(styles)
  if self then self:insert(retinaText) end
  return retinaText
end

function DisplayFactory:newEmbossedText(styles)
  local embossedText = mexico.EmbossedText(styles)
  if self then self:insert(embossedText) end
  return embossedText
end

return DisplayFactory