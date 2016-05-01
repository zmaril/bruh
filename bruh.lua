local io        = require('io');
local table     = require('table');
local ffi       = require('ffi');
local inspect   = require('inspect');
local S         = require('syscall');
local signal    = require "posix.signal"
local unistd    = require "posix.unistd"
local posix     = require('posix')
local nr        = require("syscall." .. S.abi.os .. "." .. S.abi.arch .. ".nr")
local constants = require("syscall." .. S.abi.os .. "." .. S.abi.arch .. ".constants")

c = ffi.cdef [[
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
long ptrace(enum __ptrace_request request, pid_t pid, void *addr, void *data);
typedef struct {
        unsigned long   r15;
        unsigned long   r14;
        unsigned long   r13;
        unsigned long   r12;
        unsigned long   bp;
        unsigned long   bx;
        unsigned long   r11;
        unsigned long   r10;
        unsigned long   r9;
        unsigned long   r8;
        unsigned long   ax;
        unsigned long   cx;
        unsigned long   dx;
        unsigned long   si;
        unsigned long   di;
        unsigned long   orig_ax;
        unsigned long   ip;
        unsigned long   cs;
        unsigned long   flags;
        unsigned long   sp;
        unsigned long   ss;
        unsigned long   fs_base;
        unsigned long   gs_base;
        unsigned long   ds;
        unsigned long   es;
        unsigned long   fs;
        unsigned long   gs;
}  user_regs_struct ; 
]]

debug = true 

function child_say(s)  if debug then print("[CHILD]:"  .. inspect(s)) end end
function parent_say(s) if debug then print("[PARENT]:" .. inspect(s)) end end


function run_target(arg)
  n = ffi.C.ptrace(ffi.C.PTRACE_TRACEME,0,null,null)
  local path = string.sub(io.popen("which " .. arg[1]):read("*a"),1,-2)
  new_arg = {}
  for k,v in pairs(arg) do
    if k >= 1 then
      new_arg[k] = v
    end
  end
  S.execve(path,new_arg,{})
end

function run_debugger(child_pid)
  local w, err, t = S.waitpid(-1, "all");
  ffi.errno()
  regs = ffi.new("user_regs_struct");
  print(ffi.C.ptrace(ffi.C.PTRACE_GETSIGINFO,child_pid,null,ffi.cast("void *",  regs)))
  print(regs.fs)
  print(ffi.errno())
  print("FINISHED")

  ffi.errno(0)
  print(ffi.C.ptrace(ffi.C.PTRACE_CONT,w,null,ffi.cast("void *",signal.SIGKILL)));
  print(ffi.errno())
end

function go() 
  ffi.errno(0)
  child_pid = posix.fork()
  if (child_pid == 0) then
    run_target(arg)
  else
    run_debugger(child_pid)
  end
end

go()
