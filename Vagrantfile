# encoding: utf-8
# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

current_dir    = File.dirname(File.expand_path(__FILE__))
configs        = YAML.load_file("#{current_dir}/config.yaml")
vagrant_config = configs['config']

Vagrant.configure(vagrant_config['api_version']) do |config|
    # Base box to build off, and download URL for when it doesn't exist on the user's system already
	config.vm.box = "ubuntu/trusty32"
	config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-i386-vagrant-disk1.box"
	config.vm.define :"PythonDevEnv"

	# Forward a port from the guest to the host, which allows for outside
	# computers to access the VM, whereas host only networking does not.

    # MySQL and SSH
    config.vm.network :forwarded_port, guest: 22, host: vagrant_config['ssh_port'], id: 'ssh'
    config.vm.network :forwarded_port, guest: 3306, host: vagrant_config['mysql_port']

	# Share an additional folder to the guest VM.
	config.vm.synced_folder ".", "/home/vagrant/" + vagrant_config['project_root_dir'], create: true, id: "project"

	# Enable provisioning with a shell script.
	config.vm.provision :shell, :path => "install/install.sh", :args => [vagrant_config['project_name'],vagrant_config['db_name'],vagrant_config['db_user'],vagrant_config['project_root_dir']]
end
