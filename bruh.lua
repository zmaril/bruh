io = require('io');
table = require('table');
ffi = require('ffi');
inspect = require('inspect');
S = require('syscall');

nr = require("syscall." .. S.abi.os .. "." .. S.abi.arch .. ".nr")

function remove_fn(item)
  if type(item) ~= "function" and type(item) ~= "cdata" then return item end
end

--[[function p(o)
  print(inspect(o,{depth=2,process=remove_fn}))
  end]]--


function p(o)
  print(inspect(o,{depth=1}))
end

ffi.cdef [[
enum __ptrace_request
{
  PTRACE_TRACEME = 0,
  PTRACE_PEEKTEXT = 1,
  PTRACE_PEEKDATA = 2,
  PTRACE_PEEKUSER = 3,
  PTRACE_POKETEXT = 4,
  PTRACE_POKEDATA = 5,
  PTRACE_POKEUSER = 6,
  PTRACE_CONT = 7,
  PTRACE_KILL = 8,
  PTRACE_SINGLESTEP = 9,
  PTRACE_GETREGS = 12,
  PTRACE_SETREGS = 13,
  PTRACE_GETFPREGS = 14,
  PTRACE_SETFPREGS = 15,
  PTRACE_ATTACH = 16,
  PTRACE_DETACH = 17,
  PTRACE_GETFPXREGS = 18,
  PTRACE_SETFPXREGS = 19,
  PTRACE_SYSCALL = 24,
  PTRACE_SETOPTIONS = 0x4200,
  PTRACE_GETEVENTMSG = 0x4201,
  PTRACE_GETSIGINFO = 0x4202,
  PTRACE_SETSIGINFO = 0x4203
};
extern long int ptrace (enum __ptrace_request __request, ...);
]]
debug = true 

function child_say(s)
  if debug then
    print("[CHILD]:" .. inspect(s))
  end
end

function parent_say(s)
  if debug then
    print("[PARENT]:" .. inspect(s))
  end
end

function run_target(arg) 
  child_say("Running the following:")
  child_say(arg)
  local path = string.sub(io.popen("which " .. arg[1]):read("*a"),1,-2)
  child_say(path)
  new_arg = {}
  for k,v in pairs(arg) do
    if k >= 1 then
      new_arg[k] = v
    end
  end
  child_say(new_arg)
  child_say(ffi.C.ptrace(ffi.C.PTRACE_TRACEME,0,0,0))
  S.execve(path,new_arg,{})
end

function run_debugger(child_pid)

end

function go() 
  child_pid = S.fork()
  if (child_pid == 0) then
    child_say("I LIVE")
    run_target(arg)
  else
    parent_say("TIME TO WATCH THEIR EVERY MOVE WITH PRIDE IN MY EYES AND FEAR IN MY HEART")
    run_debugger(child_pid)
  end
end

go()
