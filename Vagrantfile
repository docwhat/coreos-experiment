# -*- mode: ruby -*-
# # vi: set ft=ruby :

require 'fileutils'

Vagrant.require_version '>= 1.6.0'
TOP_DIR = File.dirname(__FILE__)

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
    vb.memory = 768
    vb.cpus = 1
  end

  config.vm.define 'master', primary: true do |master|
    master.vm.hostname = 'master'
    master.vm.network :private_network, ip: '172.17.8.100'
    master.vm.network 'forwarded_port', guest: 8080, host: 8080

    {
      'vagrantfile-user-data' => 'master.yml',
      'apiserver.crt' => 'certs/server.crt',
      'apiserver.key' => 'certs/server.key',
      'ca.crt' => 'certs/ca.crt',
      'known_tokens.csv' => 'known_tokens.csv'
    }.each_pair do |dest, src|
      master.vm.provision :file, run: 'always', source: File.join(TOP_DIR, src), destination: "/tmp/#{dest}"
    end
    master.vm.provision(:shell, run: 'always', inline: <<-SHELL, privileged: true)
set -eu
# Disable IPv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6

mv -f /tmp/vagrantfile-user-data  /var/lib/coreos-vagrant/vagrantfile-user-data

mkdir -p /var/run/kubernetes
mv -f /tmp/apiserver.crt /var/run/kubernetes/apiserver.crt
# TODO chmod/chown key
mv -f /tmp/apiserver.key /var/run/kubernetes/apiserver.key
mv -f /tmp/ca.crt /var/run/kubernetes/ca.crt

# TODO chmod/chown csv
mv -f /tmp/known_tokens.csv /var/run/kubernetes/known_tokens.csv
    SHELL
  end

  (1..ENV.fetch('NUM_NODES', 3).to_i).each do |num|
    config.vm.define "node#{num}" do |node|
      node.vm.hostname = "node#{num}"
      node.vm.network :private_network, ip: "172.17.8.#{100 + num}"

      {
        'vagrantfile-user-data' => 'node.yml',
        'kubecfg.crt' => 'certs/kubecfg.crt',
        'kubecfg.key' => 'certs/kubecfg.key',
        'ca.crt' => 'certs/ca.crt',
        'kube-proxy-kubeconfig' => 'kubeconfig.json',
        'kubelet-kubeconfig'    => 'kubeconfig.json'
      }.each_pair do |dest, src|
        node.vm.provision :file, run: 'always', source: File.join(TOP_DIR, src), destination: "/tmp/#{dest}"
      end

      node.vm.provision(:shell, run: 'always', inline: <<-SHELL, privileged: true)
set -eu
# Disable IPv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6

mv -f /tmp/vagrantfile-user-data  /var/lib/coreos-vagrant/vagrantfile-user-data

mkdir -p /var/lib/kube-proxy
mv -f /tmp/kube-proxy-kubeconfig /var/lib/kube-proxy/kubeconfig

mkdir -p /var/lib/kubelet
mv -f /tmp/kubelet-kubeconfig /var/lib/kubelet/kubeconfig

mkdir -p /var/run/kubernetes
cat /tmp/kubecfg.crt /tmp/ca.crt > /var/run/kubernetes/kubecfg.crt
rm -f /tmp/kubecfg.crt /tmp/ca.crt
# TODO chmod/chown
mv -f /tmp/kubecfg.key /var/run/kubernetes/kubecfg.key
      SHELL
    end
  end
end
