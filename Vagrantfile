# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "hashicorp/precise64"

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "shell", inline: <<-SHELL
     set -e
     sudo apt-get update
     sudo apt-get install -y git htop luarocks

     #Install luajit
     git clone http://luajit.org/git/luajit-2.0.git
     cd luajit-2.0
     make && make install
     cd -

     #Install ljsyscall locally
     git clone https://github.com/justincormack/ljsyscall.git
     cd ljsyscall
     luarocks install rockspec/ljsyscall-scm-1.rockspec
     sudo luarocks install inspect
     sudo luarocks install luaposix
   SHELL
end
