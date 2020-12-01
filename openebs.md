# Guía de OpenEbs
OpenEBS es un proyecto open source enfocado en la gestión de volúmenes dentro de kubernetes, adopta el concepto Container Attached Storage (CAS), donde cada carga de trabajo con un controlador de almacenamiento dedicado. OpenEBS impplementa políticas de almacenamiento granulares y aislamiento que permiten a los usuarios optimizar el almacenamiento para cada carga de trabajo específica. OpenEBS está completamente integrado en el espacio de usuario, lo que lo hace altamente portatil para ejecutarse en cualquier sistema operativo o plataforma.

OpenEBS es una colección de motores de almacenamiento que nos permite elegir la solución de almacenamiento adecuada para las cargas de trabajo con estado y el tipo de plataforma Kubernetes.

Cuando se usa la replicación síncrona, iSCSI se usa para conectar el almacenamiento de OpenEBS a los pods de aplicaciones. Por lo tanto, OpenEBS requiere que se configure el cliente iSCSI y que el servicio iscsid se ejecute en los nodos trabajadores. Es importante verificar si el servicio iSCSI está en funcionamiento antes de comenzar la instalación.

### Prerequisitos (iSCSI client)
La instalación del servicio y las herramientas del iniciador iSCSI depende del sistema operativo de su host o del contenedor de kubelet.
Instalamos iSCSI unicamente en los nodos donde se gestionen los volúmenes.
```bash
$ sudo apt install open-iscsi
$ sudo systemctl enable --now iscsid
$ modprobe iscsi_tcp
$ echo iscsi_tcp >/etc/modules-load.d/iscsi-tcp.conf
```
Verificamos que el servicio se haya levanto sin problemas.
```bash
$ sudo service iscsid status
```
Algo importante es que los volúmenes deben estar vinculados al nodo, sin formato ni montados en ningun directorio.

### Instalación de Openebs
A continuación, instalaremos openebs con cstor-operator:

Primero Creamos un namespace para openEbs
```bash
$ kubectl create namespace openebs
```
Implementamos el siguiente manifiesto:
```bash
$ kubectl apply -f https://openebs.github.io/charts/cstor-operator.yaml
```

### Instalación del dev mode
Como alternativa, se puede instalar la versión dev de openEBS con los siguientes pasos:
```
$ git clone https://github.com/openebs/cstor-operators.git
$ cd cstor-operators
$ kubectl create -f deploy/rbac.yaml
$ kubectl create -f deploy/ndm-operator.yaml
$ kubectl create -f deploy/crds
$ kubectl create -f deploy/cstor-operator.yaml
$ kubectl create -f deploy/csi-operator.yaml
```

### verificamos que el Node Disk Manager y el cStor operator hayan sido desplegados correctamente:

```shell
$ kubectl get pod -n openebs
# result:
NAME                                                              READY   STATUS    RESTARTS   AGE
cspc-operator-5fb7db848f-wgnq8                                    1/1     Running   0          6d7h
cvc-operator-7f7d8dc4c5-sn7gv                                     1/1     Running   0          6d7h
openebs-cstor-admission-server-7585b9659b-rbkmn                   1/1     Running   0          6d7h
openebs-cstor-csi-controller-0                                    7/7     Running   0          6d7h
openebs-cstor-csi-node-dl58c                                      2/2     Running   0          6d7h
openebs-cstor-csi-node-jmpzv                                      2/2     Running   0          6d7h
openebs-cstor-csi-node-tfv45                                      2/2     Running   0          6d7h
openebs-ndm-gctb7                                                 1/1     Running   0          6d7h
openebs-ndm-operator-7c8759dbb5-58zpl                             1/1     Running   0          6d7h
openebs-ndm-sfczv                                                 1/1     Running   0          6d7h
openebs-ndm-vgdnv                                                 1/1     Running   0          6d6h

```

#### Etiquetar los nodos gestores de volúmenes
Es necesario marcar los nodos agregandoles labels para posteriormente crear nuestro pool de volumenes:

```bash
$ kubectl label nodes <nombrenodo> node=openebs
```

### Creación del CStorPoolCluster
listamos todos los blockdevices vinculados a openebs
```shell
$ kubectl get bd -n openebs
# result:
NAME                                           NODENAME   SIZE         CLAIMSTATE   STATUS     AGE
blockdevice-6863f96af8a13b87b400d2db5426d6a2   worker3    8588886016   Unclaimed    Inactive   32m
blockdevice-d911961401359f6ae22cb1be03ab6f0a   worker3    8588886016   Unclaimed    Inactive   32m
blockdevice-ecf0d8a02844891db0cd0d2ce9c98268   worker3    8588886016   Unclaimed    Inactive   32m
```
creamos un archivo cstor.yaml con el siguiente contenido:
```yaml
# cstor.yaml
apiVersion: cstor.openebs.io/v1
kind: CStorPoolCluster
metadata:
  name: cspc-raidz
  namespace: openebs
spec:
  pools:
    - nodeSelector:
        kubernetes.io/hostname: "worker3"
        node: "openebs"
      dataRaidGroups:
      - blockDevices:
          - blockDeviceName: "blockdevice-6863f96af8a13b87b400d2db5426d6a2"
          - blockDeviceName: "blockdevice-d911961401359f6ae22cb1be03ab6f0a"
          - blockDeviceName: "blockdevice-ecf0d8a02844891db0cd0d2ce9c98268"
      poolConfig:
        dataRaidGroupType: "raidz"
```
```shell
$ kubectl apply -f cstor.yaml
```
Verificamos que el pool haya sido creado correctamente:
```shell
$ kubectl get cspc -n openebs
$ kubectl get cstorvolume -n openebs
$ kubectl get cstorvolumereplica -n openebs
```


### definición del storage class
creamos un storage class de prueba de la siguiente manera
```yaml
# sc.yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: cstor-csi-raidz-test
provisioner: cstor.csi.openebs.io
allowVolumeExpansion: true
parameters:
  cas-type: cstor
  cstorPoolCluster: cspc-raidz
  replicaCount: "1"
```
```shell
$ kubectl apply -f sc.yaml
```
### definición del PVC
declaramos el Persisten Volume Claim:

```yaml
# sc.yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: demo-cstor-vol
spec:
  storageClassName: cstor-csi-stripe
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```
```shell
$ kubectl apply -f sc.yaml
```
### pod de prueba
Finalmente, creamos un pod para usar el volumen montado:
```yaml
#test-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: busybox
  namespace: default
spec:
  containers:
  - command:
       - sh
       - -c
       - 'date >> /mnt/openebs-csi/date.txt; hostname >> /mnt/openebs-csi/hostname.txt; sync; sleep 5; sync; tail -f /dev/null;'
    image: busybox
    imagePullPolicy: Always
    name: busybox
    volumeMounts:
    - mountPath: /mnt/openebs-csi
      name: demo-vol
  volumes:
  - name: demo-vol
    persistentVolumeClaim:
      claimName: demo-cstor-vol
```
```shell
$ kubectl apply -f test-pod.yaml
```
Verificamos que el pod que esta corriendo esté habilitado para escribir información
```shell
$ kubectl get pods
```
El pod de ejemplo esta programado para escribir los datos cuando inicie en el directorio /mnt/openebs-csoi/date.txt
```shell
$ kubectl exec -it busybox -- cat /mnt/openebs-csi/date.txt
Wed Jul 12 07:00:26 UTC 2020
```
