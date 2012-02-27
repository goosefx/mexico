local mexico = require "mexico"

--
-- Queue
--
-- Properties:
--  + size [number] : The number of items in the queue.
--
local Queue = mexico.class(false)

function Queue:init()
  self.size   = 0
  self._items = {}
end

function Queue:enqueue(item)
  table.insert(self._items, item)
  self.size = self.size + 1
end
 
function Queue:dequeue()
  if (self.size < 1) then return nil end
  self.size = self.size - 1
  return table.remove(self._items, 1)
end
 
function Queue:peek()
  if (self.size < 1) then return nil end
  return self._items[1]
end

return Queue