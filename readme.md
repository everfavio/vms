### instalación y configuración de un cluster de servers
instalamos los paquetes necesarios y vagrant
```
sudo apt-get install vagrant
apt-get install qemu libvirt-daemon-system libvirt-clients ebtables dnsmasq-base
apt-get install libxslt-dev libxml2-dev libvirt-dev zlib1g-dev ruby-dev
```

instalamos el plugin para vagrant

```
mkdir -p ~/tmp/
cd ~/tmp/
git clone https://github.com/jcf/vagrant-libvirt
cd ./vagrant-libvirt/
git checkout upgrade-nokogiri
gem build vagrant-libvirt.gemspec
vagrant plugin install  ~/tmp/vagrant-libvirt/vagrant-libvirt-0.0.37.gem
```



El vagrantfile define 6 boxes debian 10, con 2 gb de ram y 2 cores para tres nodos master  y 1gb de ram con 1 core para los nodos workers, que son los requerimientos mínimos que pide un cluster kubernetes