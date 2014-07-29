# -*- mode: ruby -*-
# vi: set ft=ruby :

# Use vagrant up to setup the box.
# vagrant ssh if you need to edit anything on the server
# vagrant destroy to start over from scratch
# As i standard with vagrant machines, the
# vagrant user has passwordless sudo access on the guest machine

Vagrant.configure("2") do |config|

  #Ubuntu 14.04 Server 64-bit box supporting VirtualBox and VMware providers. 
  config.vm.box = "misheska/ubuntu1404"

  config.vm.hostname = "horrible.ddos.server.com"
  config.vm.provision "shell", path: 'setup.sh'

  # https://github.com/smdahlen/vagrant-digitalocean
  # Use vagrant up --provider=digital_ocean to setup a
  # drople on digitalocean, not a Virtualbox/Vmware guest.
  config.vm.provider :digital_ocean do |provider, override|
    override.ssh.private_key_path = '~/.ssh/id_rsa'
    override.vm.box = 'digital_ocean'
    override.vm.box_url = "https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box"

    provider.token = 'Get your token at https://cloud.digitalocean.com/settings/applications -> Personal Access Tokens'
    provider.image = 'Ubuntu 14.04 x64'
    provider.region = 'ams1'
    provider.size = '512mb'
  end
end
