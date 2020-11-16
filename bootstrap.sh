#!/usr/bin/env bash
# establecemos la interfaz de debian como no interactiva
export DEBIAN_FRONTEND=noninteractive
# instalamos los paquetes necesario
apt-get update
apt-get -y install net-tools
apt-get -y install build-essential
apt-get -y install vim
#configurando ssh user
sed -i "/^[^#]*PasswordAuthentication[[:space:]]no/c\PasswordAuthentication yes" /etc/ssh/sshd_config
systemctl restart sshd.service
## creamos el usuario
useradd -m -s /bin/bash kubernetes
## establecemos la contraseña ('usuario:password')
echo 'kubernetes:kubernetes' | chpasswd
## agregamos al nuevo usuario al grupo sudoers
echo 'kubernetes  ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
## generamos las llaves ssh para habilitar la autenticación ssh
sudo su kubernetes
cd
ssh-keygen -t dsa -N "kubernetes" -f "$HOME/.ssh/id_rsa"
exit