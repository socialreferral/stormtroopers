# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  config.vm.host_name = "stormtroopers"
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"
  config.vm.share_folder "v-root", "/vagrant", "."
  config.vm.provision :shell, :path => "vagrant-provision"
end
