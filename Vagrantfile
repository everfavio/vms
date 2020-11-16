Vagrant.configure("2") do |config|
  # config.vm.provision "shell", inline: "echo hello"
  config.ssh.insert_key = false
  config.vm.define "master1" do |master1|
    master1.ssh.insert_key = false
    master1.vm.network :private_network, ip: "192.168.0.17"
    master1.vm.box = "debian/buster64"
    master1.vm.hostname = "master1"
    master1.vm.boot_timeout = 500
    master1.vm.provision :shell, path: "bootstrap.sh"
    master1.vm.provider :virtualbox do |vb|
      vb.gui = false
      vb.customize ["modifyvm", :id, "--memory", "2048"]
      vb.customize ["modifyvm", :id, "--cpus", "2"]
    end
  end
  config.vm.define "master2" do |master2|
    master2.vm.box = "debian/buster64"
    master2.vm.network :private_network, ip: "192.168.0.18"
    master2.vm.hostname = "master2"
    master2.vm.boot_timeout = 500
    master2.vm.provision :shell, path: "bootstrap.sh"
    master2.vm.provider :virtualbox do |vb|
      vb.gui = false
      vb.customize ["modifyvm", :id, "--memory", "2048"]
      vb.customize ["modifyvm", :id, "--cpus", "2"]
    end
  end
  config.vm.define "master3" do |master3|
    master3.vm.box = "debian/buster64"
    master3.vm.network :private_network, ip: "192.168.0.19"
    master3.vm.hostname = "master3"
    master3.vm.boot_timeout = 500
    master3.vm.provision :shell, path: "bootstrap.sh"
    master3.vm.provider :virtualbox do |vb|
      vb.gui = false
      vb.customize ["modifyvm", :id, "--memory", "2048"]
      vb.customize ["modifyvm", :id, "--cpus", "2"]
    end
  end
  config.vm.define "worker1" do |worker1|
    worker1.ssh.insert_key = false
    worker1.vm.network :private_network, ip: "192.168.0.20"
    worker1.vm.box = "debian/buster64"
    worker1.vm.hostname = "worker1"
    worker1.vm.boot_timeout = 500
    worker1.vm.provision :shell, path: "bootstrap.sh"
    worker1.vm.provider :virtualbox do |vb|
      vb.gui = false
      vb.customize ["modifyvm", :id, "--memory", "2048"]
      vb.customize ["modifyvm", :id, "--cpus", "1"]
    end
  end
  config.vm.define "worker2" do |worker2|
    worker2.vm.box = "debian/buster64"
    worker2.vm.network :private_network, ip: "192.168.0.21"
    worker2.vm.hostname = "worker2"
    worker2.vm.boot_timeout = 500
    worker2.vm.provision :shell, path: "bootstrap.sh"
    worker2.vm.provider :virtualbox do |vb|
      vb.gui = false
      vb.customize ["modifyvm", :id, "--memory", "2048"]
      vb.customize ["modifyvm", :id, "--cpus", "1"]
    end
  end
  config.vm.define "worker3" do |worker3|
    worker3.vm.box = "debian/buster64"
    worker3.vm.network :private_network, ip: "192.168.0.22"
    worker3.vm.hostname = "worker3"
    worker3.vm.boot_timeout = 500
    worker3.vm.provision :shell, path: "bootstrap.sh"
    worker3.vm.provider :virtualbox do |vb|
      vb.gui = false
      vb.customize ["modifyvm", :id, "--memory", "2048"]
      vb.customize ["modifyvm", :id, "--cpus", "1"]
    end
  end
  config.vm.define "worker4" do |worker4|
    worker4.vm.box = "debian/buster64"
    worker4.vm.network :private_network, ip: "192.168.0.23"
    worker4.vm.hostname = "worker4"
    worker4.vm.boot_timeout = 500
    worker4.vm.provision :shell, path: "bootstrap.sh"
    worker4.vm.provider :virtualbox do |vb|
      vb.gui = false
      vb.customize ["modifyvm", :id, "--memory", "2048"]
      vb.customize ["modifyvm", :id, "--cpus", "1"]
    end
  end
end
