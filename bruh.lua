ffi = require('ffi');
inspect = require('inspect');
S = require('syscall');

nr = require("syscall." .. S.abi.os .. "." .. S.abi.arch .. ".nr")

function remove_fn(item)
  if type(item) ~= "function" and type(item) ~= "cdata" then return item end
end

function p(o)
  print(inspect(o,{depth=2,process=remove_fn}))
end

p(nr.SYS)
