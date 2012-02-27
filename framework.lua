--
-- mexico string extensions
--
string.mexico = {
  --
  -- Function: string.split (extension function)
  --
  -- The split function is used to split a string into an array of substrings.
  --
  -- Parameters:
  --  + separator [string] : Specifies the character (or character sequence) to use for splitting the string. 
  --  + maxSplit  [number] : (optional) The maximum number of splits.
  --  + isRegEx   [bool]   : (optional) Specifies if 'parameter' is a regular expression.
  --
  -- Returns:
  -- Returns the new array.
  --
  split = function (str, separator, maxSplit, isRegEx)
  	assert(separator and separator ~= '', "The 'separator' parameter SHOULD NOT be null or empty.")
  	assert(maxSplit == nil or maxSplit >= 1, "The 'maxSplit' parameter MUST be greater or equal 1.")
  
  	local result = {}
  
  	if string.len(str) > 0 then
  		local asPlain = not isRegEx
  		maxSplit = maxSplit or -1
  
  		local pos=1 start=1
  		local first,last = string.find(str, separator, start, asPlain)
  		while first and maxSplit ~= 0 do
  			result[pos] = string.sub(str, start, first-1)
  			pos = pos+1
  			start = last+1
  			first,last = string.find(str, separator, start, asPlain)
  			maxSplit = maxSplit - 1
  		end
  		result[pos] = string.sub(str, start)
  	end
  
  	return result
  end,
  	
}
-- shortcuts 
string.split = string.mexico.split

--
-- mexico table extensions
--
table.mexico = {
  --
  --
  --
  indexOf = function(tbl, value)
    if not tbl then return false end
    for i,v in ipairs(tbl) do
      if v == value then return i end
    end
    return false
  end,
  --
  --
  --
  removeValue = function(tbl, value)
    if not self then return false end
    local i = table.mexico.indexOf(tbl, value)
    if (i > 0) then
      table.remove(tbl, i)
      return true
    end
    return false
  end,

  --
  --
  --
  clone = function(tbl, deep)
    if not tbl then return nil end
    local new = {}             
    local i, v = next(tbl, nil) 
    while i do
      if deep and (type(v) == "table") then 
        v = table.mexico.clone(v, deep) 
      end
      new[i] = v
      i, v = next(tbl, i) 
    end
    return new
  end
}
-- shortcuts 
table.indexOf = table.mexico.indexOf
table.removeValue = table.mexico.removeValue
table.clone = table.mexico.clone

--  
-- init mexico
--
local mexico = {
  
  --
  -- Function: fargs
  --
  -- Returns variable arguments function as <array>, <num>. 
  --
  fargs = function(...)
    local args = {...}
    local nargs = #args
    return args, nargs
  end,

  --
  -- Function: namespace
  --
  namespace = function(name)
    name = name .. "_mx_nsLoader"
    if package.loaded[name] then
      return package.loaded[name]
    end
    local ns_mt = {
      __index = function(table, key)
        local mod_name = name .. "." .. key
        local value    = require(mod_name)
        table[key]     = value
        return value  
      end,
    }
    local ns = {}
    setmetatable(ns, ns_mt)  
    table["ui"] = ns
    package.loaded[name] = ns
    return ns
  end,
    
  --
  --
  -- Function: class
  --
  -- Creates a lightweight lua class.
  -- 
  -- Parameters:
  --  + base    [table] : (optional) The base class to inherit from (if not specified, Object will be used).
  --
  -- Original Version: http://lua-users.org/wiki/SimpleLuaClasses
  class = function(base, ...)
    local c = {} 
    -- no base, use Object
    if not base then base = package.loaded["Object"] end
    -- check if we have to inherit from a base class
    if type(base) == 'table' then
      -- our new class is a shallow copy of the base class!
      for k,v in pairs(base) do
        c[k] = v
      end
      c._base = base      -- base class reference
      c.init  = base.init -- use base init if class does not have one
      c.new   = base.new  -- use base new if class does not have one
  
    end
    -- check if we have some mixin objects
    c._mixins = {...}
    for i,m in ipairs(c._mixins) do 
      for k,v in pairs(m) do
        -- never overload existing functions and never attach init functions
        if (type(v) == "function") and (not c[k]) and (k ~= "init") then 
          c[k] = v 
        end
      end
    end
    
    -- the class will be the metatable for all its objects,
    -- and they will look up their methods in it.
    c.__index = c
    c.__tostring = function(c_tbl, ...) if c_tbl then return c_tbl:toString(...) else return nil end end 
    
    -- expose a constructor which can be called by <classname>(<args>)
    local ctor_metatable = {
      __call = function(c_tbl, ...) 
        local obj
        if type(c.new) == "function" then
          obj = c.new(...)
          assert(obj, "new(...) did not returned a value")
          -- setmetatable does not work here so copy all functions
          for k,v in pairs(c) do
            if type(v) == "function" then       -- copy only functions
              if obj[k] then                    -- function already exist
                obj["original_" .. k] = obj[k]  -- rename original function to "original_<func_name>"
              end
              obj[k] = v                        -- attach class function to object instance
            end
          end
        else  
          obj = {}                              -- true object creation
          setmetatable(obj, c)                  -- just set class metatable to object -> done
        end
        if c.init then c.init(obj, ...) end     -- call object constructor (or better initializer)
        return obj                              -- return the new object
      end,
    }
    -- set class metatable
    setmetatable(c, ctor_metatable) 
    return c -- return class
  end,
  
  -- run method
  run = function(filename)
    local app require(filename or "app")
    package.loaded["mexico"]["app"] = app
    return app
  end,
}

local mexico_mt = {
  --
  -- Dynamic load a mexico module
  --
  __index = function(table, key)
    if (key == "ui") then             -- ui namespace
      local ui_mt = {
        __index = function(table, key)
          local mod_name = "mexico.ui." .. key
          local value    = require(mod_name)
          table[key]     = value
          return value  
        end,
      }
      local ui = {}
      setmetatable(ui, ui_mt)  
      table["ui"] = ui
      return ui
    else
      if (key == "gc") then                 -- garbage collector singleton
        key = "GarbageCollector"
      end
      local mod_name = "mexico." .. key
      local value    = require(mod_name)
      table[key]     = value
      return value  
    end
  end,
}

setmetatable(mexico, mexico_mt)  

--
-- Class: Object
--
-- Base class for all objects.
--
local Object = mexico.class(false)

--
-- Constructor
--
function Object:init()
  Object.assert(self)
end

--
-- Assert if object is not nil and not already disposed.
--
function Object:assert()
  assert(self, "Object is nil.")
  assert(not self.disposed, "Object is disposed.")
end

-- 
-- Function: dispose
--
-- Releases all resources used by the object.
--
-- Remarks:
-- Call this function if you no longer need the object. The garbage collector will thank you!
--
function Object:dispose()
  self["disposed"] = true -- mark object as disposed
end

--
-- Function: toString
--
-- Returns a string that represents the current object.
--
-- Returns:
-- The default implementation will return the full type name of the object (like: Object).
--
-- Remarks:
-- Always override this function and not __tostring, since __tostring is already mapped to this function!
--
function Object:toString()
  return "Object"
end

-- register mexico shortcut
package.loaded["mexico"] = mexico

-- register Object
package.loaded["mexico.Object"] = Object


-- return package content
return mexico



