# vi: set ft=ruby :

# Builds VMs using a JSON template file and bash
nodes_config = (JSON.parse(File.read("nodes.json")))['nodes']

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  nodes_config.each do |node|
    node_name   = node[0] # name of node
    node_values = node[1] # content of node

    config.vm.define node_name do |config|
      # configures all forwarding ports in JSON array
      ports = node_values['ports']
      ports.each do |port|
        config.vm.network :forwarded_port,
          host:  port[':host'],
          guest: port[':guest'],
          id:    port[':id']
      end

      config.vm.box = nodes_config[node_name][':os_image']
      config.vm.hostname = node_name
      config.vm.network :forwarded_port, guest: node_values[':guest'], host: node_values[':host']

      config.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--memory", node_values[':memory']]
        vb.customize ["modifyvm", :id, "--name", node_name]
      end

      provisioner = node_values[':provisioner']
      config.vm.provision "fix-no-tty", type: "shell" do |s|
          s.privileged = false
          s.inline = "sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile"
      end
      if provisioner == 'bash_script'
        config.vm.provision :shell, :path => node_values[':bootstrap']
      else
        config.vm.provision :ansible, :playbook => node_values[':ansible_playbook']
      end
    end
  end
end
