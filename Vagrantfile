# -*- mode: ruby -*-
# # vi: set ft=ruby :

require 'fileutils'

Vagrant.require_version '>= 1.6.0'

Vagrant.configure('2') do |config|
  # always use Vagrants insecure key
  config.ssh.insert_key = false

  config.vm.box = 'coreos-stable'
  config.vm.box_url = 'http://stable.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json'

  config.vm.provider :virtualbox do |v|
    # On VirtualBox, we don't have guest additions or a functional vboxsf
    # in CoreOS, so tell Vagrant that so it can be smarter.
    v.check_guest_additions = false
    v.functional_vboxsf     = false
  end
  config.vbguest.auto_update = false if Vagrant.has_plugin?('vagrant-vbguest')

  config.vm.provider :virtualbox do |vb|
    vb.gui = false
    vb.memory = 1024
    vb.cpus = 1
  end

  config.vm.define 'master', primary: true do |master|
    master.vm.hostname = 'master'
    master.vm.network :private_network, ip: '172.17.8.100'
    master.vm.network 'forwarded_port', guest: 8080, host: 8080

    master.vm.provision(
      :file,
      source: File.expand_path('../master.yml', __FILE__),
      destination: '/tmp/vagrantfile-user-data'
    )
    master.vm.provision(
      :shell,
      inline: 'mv -f /tmp/vagrantfile-user-data /var/lib/coreos-vagrant/',
      privileged: true
    )
  end

  (1..ENV.fetch('NUM_NODES', 1).to_i).each do |num|
    config.vm.define "node#{num}" do |node|
      node.vm.hostname = "node#{num}"
      node.vm.network :private_network, ip: "172.17.8.#{100 + num}"

      node.vm.provision(
        :file,
        source: File.expand_path('../node.yml', __FILE__),
        destination: '/tmp/vagrantfile-user-data'
      )
      node.vm.provision(
        :shell,
        inline: 'mv -f /tmp/vagrantfile-user-data /var/lib/coreos-vagrant/',
        privileged: true
      )
    end
  end
end
