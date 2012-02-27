local mexico = require "mexico"

--
-- Stack
--
-- Properties:
--  + size [number] : The number of items in the queue.
--
local Stack = mexico.class(false)

function Stack:init()
  self.size   = 0
  self._items = {}
end

function Stack:push(item)
  table.insert(self._items, item)
  self.size = self.size + 1
end
 
function Stack:pop()
  if (self.size < 1) then return nil end
  self.size = self.size - 1
  return table.remove(self._items)
end
 
function Stack:peek()
  if (self.size < 1) then return nil end
  return self._items[self.size]
end

return Stack