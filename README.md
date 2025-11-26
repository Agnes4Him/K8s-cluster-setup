# K8s-cluster-setup
A DevOps project that demostrates how to setup a 3-node Kubernetes cluster using EC2 instances.
It provides a detailed step-by-step guide.

# Prerequisite/ Requirements
* AWS Account with Administrator access or a dedicated user with privilege to create resources

* Access Key ID and Secret Access Key created for the user

* AWS CLI installed

* Terraform installed

# Setup Steps

### Launch 3 EC2 instances `t3.medium` (Ubuntu) — 1 master, 2 workers
* Create 2 SSH keys on the AWS console - `bastion-key` and `k8s-key`. The respective private keys will be automatically
downloaded locally

* Using Terraform, create the resources needed

```bash
aws configure        # And follow the prompts

cd ./infrastructures

terraform init
terraform plan
terraform apply
```

### SSH into the instances
* First SSH into bastion using the downloaded bastion-key

```bash
ssh -i <PATH_TO_BASTION_KEY> ubuntu@<BASTION_PUBLIC_IP>
```

* Copy the content of local k8s-key into a file such as `k8s-key.pem` on the bastion host

* From bastion, SSH into each of the K8s nodes

```bash
ssh -i <PATH_TO_K8S_KEY> ubuntu@<PRIVATE_IP_OF_NODE>
```

* On each K8s node instance, clone this repository

```bash
git clone <REPOSITORY_URL>
```

* Give the files in `scripts` folder executable permission and run them

```bash
chmod K8s-cluster-setup/scripts/os-prep.sh
chmod K8s-cluster-setup/scripts/containerd.sh
chmod K8s-cluster-setup/scripts/k8s-components.sh

./K8s-cluster-setup/scripts/os-prep.sh           # prepares the virtual machine
./K8s-cluster-setup/scripts/containerd.sh        # installs container runtime (containerd)
./K8s-cluster-setup/scripts/k8s-components.sh    # installs kubelet, kubeadm, kubectl
```

### Initialize control plane on master(control plane) with `kubeadm init` and save the `kubeadm join` command printed out

```bash
MASTER_IP=<CONTROL_PLANE_PRIVATE_IP>
POD_CIDR="192.168.0.0/16"   # Calico default

sudo kubeadm init --apiserver-advertise-address=${MASTER_IP} \
  --pod-network-cidr=${POD_CIDR}
```

### Setup `kubectl` for your user on control plane

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### Install a pod network (Calico) and check that the network pods are running

```bash
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/tigera-operator.yaml
curl https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/custom-resources.yaml -O
sed -i 's/cidr: 192\.168\.0\.0\/16/cidr: 10.10.0.0\/16/g' custom-resources.yaml         # If not using Calico default CIDR
kubectl create -f custom-resources.yaml

kubectl get pods -n kube-system
kubectl get pods -n calico-system         # calico-node, calico-kube-controllers, coredns, kube-proxy should be running
```

### Join each worker node using the `kubeadm join` command

```bash
kubeadm token create --print-join-command             # Run this on master if the join command wasn't copied earlier or if token is expired

sudo kubeadm join <CONTROL_PLANE_PRIVATE_IP>:6443 --token ... --discovery-token-ca-cert-hash <SHA>
```

### Verify cluster health

```bash
kubectl get nodes
kubectl get pods -A
```

### Allow workloads to run on control plane

```bash
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```

* NB
Ports used in the security groups and their roles
- 22 : SSH

- 6443 : Kubernetes API server

- 10250 : Kubelet (between control-plane and nodes)

- 2379-2380 : ETCD (If using multi control plane for HA)

- 30000-32767 : NodePort range