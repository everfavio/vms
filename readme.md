# Levantando un Kubespray Local
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

### instalación del clúster con Kubespray

Una ves los boxes definidos en nuestro vagranfile procedemos a la instalación de nuestro cluster con kubespray

#### prerequisitos

En nuestro equipo anfitrión debemos contar con la version 2.9 o superior de ansible y pip3

#### paso 0: establecer conexion ssh sin password

Desde el equipo anfitrión donde están alojados nuestros boxes ejecutamos los siguientes comandos:
```bash
# introducimos las contraseñas cada ves que sea necesario
$ ssh-copy-id kubernetes@192.168.0.17
$ ssh-copy-id kubernetes@192.168.0.18
$ ssh-copy-id kubernetes@192.168.0.19
$ ssh-copy-id kubernetes@192.168.0.20
$ ssh-copy-id kubernetes@192.168.0.21
$ ssh-copy-id kubernetes@192.168.0.22
```
#### paso 1: establecemos el inventario

#### paso 3: ejecutamos el playbook

Ejecutamos el playbook con la siguiente linea

```
$ ansible-playbook -i inventory/mycluster/inventory.ini --become --become-user=root cluster.yml -u kubernetes -vvvvvv
```
La tarea se demorará un buen tiempo dependiendo de la conexión a internet y las características del anfitrión, ya que instalará todo lo necesario para nuestro clúster kubernetes.

#### Comprobando la instalación
Una ves finalizada la instalación necesitamos realizar unas configuraciones extras para administrar nuestro clúster

```bash
 #192.168.0.17
  $ mkdir -p $HOME/.kube
  $ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  $ sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
Ahora desde la consola del servidor 192.168.0.17 podemos ejecutar todos los comandos que sean necesarios, si ejecutamos kubectl get nodes este nos listará todos nuestros boxes definidos y levantados por vagrant, con el detalle de que todos nuestros nodos workers no tienen un rol definido como es el caso de los masters (notese en la columna roles el valor < none >), es algo que podemos solucionar ejecutando los siguientes comandos:
```shell
#192.168.0.17
$ kubectl label node worker1 node-role.kubernetes.io/worker=worker
$ kubectl label node worker2 node-role.kubernetes.io/worker=worker
$ kubectl label node worker3 node-role.kubernetes.io/worker=worker
```

# Algunos ejercicios
Kubespray realiza todas las tareas definidas con ansible, cuya herramienta tiene como fin
### eliminar nodos muertos
Recurrimos a la interfaz gráfica de virtual box y apagamos los boxes worker1 y worker2, luego ejecutamos el siguiente comando
```bash
#192.168.0.17
$ kubectl get nodes
# deberiamos obtener la siguiente respuesta
master1   Ready      master   34m   v1.19.3
master2   Ready      master   33m   v1.19.3
master3   Ready      master   33m   v1.19.3
worker1   Ready      worker   32m   v1.19.3
worker2   NotReady   worker   32m   v1.19.3
worker3   NotReady   worker   32m   v1.19.3
```
Encontramos que no se puede tener acceso a esos nodos, si por una u otra razon estos nodos son irrecuperables podemos eliminarlos de nuestra lista de nodos ejecutando:
```bash
#192.168.0.17
$ kubectl delete node worker1
$ kubectl delete node worker2
```
 <!--  Run on Master
kubectl cordon <node-name>
kubectl drain <node-name> --delete-exit-data --force --ignore-daemonsets  --delete-local-data
kubectl delete node <node-name> -->
### Agregar un nuevo nodo
en nuestro vagrantfile agregamos las siguientes lineas para crear un nuevo worker

```conf
# vagrantfile
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
```
y luego ejecutamos
```bash
### host anfitrión
 $ vagrant up
```
Se creará un nuevo box sin alterar las configuraciónes y operaciones anteriormente ejecutadas en los otros boxes, la idea es usar este nuevo box y agregarlo como nuevo nodo dentro de nuestro cluster kubernetes
