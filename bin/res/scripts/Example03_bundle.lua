(function(args)
local modules = {}
modules['./res/scripts/Example03.lua'] = function(...)
--[[---------------------------------------------------------------------------

                   ______  _____    _______  _______ ™
                  |   __ \|     |_ |   |   ||   _   |
                  |    __/|       ||   |   ||       |
                  |___|   |_______||_______||___|___|
                            Lua for Pascal

                 Copyright © 2024-present tinyBigGAMES™ LLC
                          All Rights Reserved.

                   https://github.com/tinyBigGAMES/PLUA

                 See LICENSE file for license information
 ----------------------------------------------------------------------------]]
  
print("this is a compiled lua script...")
local mm = import("./res/scripts/mymath.lua")
mm.add(50,50)
end
modules['./res/scripts/mymath.lua'] = function(...)
local mymath =  {}

function mymath.add(a,b)
   print(a+b)
end

function mymath.sub(a,b)
   print(a-b)
end

function mymath.mul(a,b)
   print(a*b)
end

function mymath.div(a,b)
   print(a/b)
end                    

function mymath.test()
  print('test')
end

function mymath.test2()
  print('test2')     
end

return mymath    
end
function import(n)
return modules[n](table.unpack(args))
end
local entry = import('./res/scripts/Example03.lua')
end)({...})