### Preparación de un entorno de maquinas virtuales con Vagrant

pequeña guía para levantar un set de boxes vagrant para posteriormente levantar un cluster kubernetes con kubespray

Nota: todos los pasos solo fueron probados en un equipo con debian 10 como anfitrión

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

Actualmente el provider instala los paquetes básicos, registra un nuevo usuario kubernetes y habilita el acceso ssh en todas las vms.

Se han dejado las contraseñas de manera sencilla:
```
usuario     pass
vagrant     vagrant
kubernetes  kubernetes
```
Se han creado los nodos con las siguientes configuraciones de ip:
```
hostname      ip
master1       192.168.0.17
master2       192.168.0.18
master3       192.168.0.19
worker1       192.168.0.20
worker2       192.168.0.21
worker3       192.168.0.22
```


la idea es que desde este punto se tenga un ambiente predefinido para ejecutar kubespray y realizar posteriores ejercicios de administración del cluster, como agregaar o quitar nodos.

TODO:
- parametrizar todo lo que se pueda y optimizar los procesos repetitivos del vagrantfile.
- mejorar el archivo bootstrap.sh
- hacer un readme mas digno xD
