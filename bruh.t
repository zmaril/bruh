math      = require('math')
table     = require('table');
inspect   = require('inspect');
string    = require('string');
ptrace = terralib.includec("sys/ptrace.h")
unistd = terralib.includec("unistd.h")
syscall = terralib.includec("sys/syscall.h")


numbers_to_syscall = {}

m = 0
i = 0
for k,v in pairs(syscall) do
  if string.sub(k,0,4) == "__NR" then
    numbers_to_syscall[v] = string.sub(k,6)
    i = i + 1
    m = math.max(v,m)
  end
end

print(i)
print(m)
print(table.getn(numbers_to_syscall))


print(inspect(numbers_to_syscall))
read = unistd[numbers_to_syscall[0]]

print(inspect(read.type.parameters[2].type,{depth=1}))
