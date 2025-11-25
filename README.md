# K8s-cluster-setup
A demo project to show-case setting up a 3-node Kubernetes cluster using virtual machines

# Setup Steps
### Create a VPC / security groups
* Allow ingres on the following ports:
- 22 : SSH

- 6443 : Kubernetes API server

- 10250 : Kubelet (between control-plane and nodes)

- 2379-2380 : ETCD (If using multi control plane for HA)

- 30000-32767 : NodePort range

### Launch 3 EC2 instances `t3.medium` (Ubuntu) — 1 master, 2 workers
* Manually create 2 SSH key on the AWS console - `bastion-key` and `k8s-key`. The private keys will be automatically
downloaded locally

* Create AWS access key id and secret key id for a user with privilge to create resources

* Using Terraform (`./infrastructures`), provision the resources needed

```bash
aws configure

cd ./infrastructures

terraform init
terraform plan
terraform apply
```

### Prepare the virtual machines OS
* Use script provided - `./scripts/os-prep.sh`

### SSH into each node and install container runtime (containerd), kubelet, kubeadm, kubectl
* Use the scripts provided in `./scripts` folder to install

### Initialize control plane on master with `kubeadm init` and save the `kubeadm join` command printed out

```bash
MASTER_IP=<CONTROL_PLANE_PRIVATE_IP>
POD_CIDR="192.168.0.0/16"   # Calico default

sudo kubeadm init --apiserver-advertise-address=${MASTER_IP} \
  --pod-network-cidr=${POD_CIDR}
```

### Setup `kubectl` for your user on control planeS

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### Install a pod network (Calico) and check that the network pods are running

```bash
# kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/tigera-operator.yaml
# kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/custom-resources.yaml

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/tigera-operator.yaml
curl https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/custom-resources.yaml -O
sed -i 's/cidr: 192\.168\.0\.0\/16/cidr: 10.10.0.0\/16/g' custom-resources.yaml
kubectl create -f custom-resources.yaml

kubectl get pods -n kube-system         # calico-node, calico-kube-controllers, coredns, kube-proxy should be running
```

### Join worker nodes using the `kubeadm join` command

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

### Run `kubectl` commands from local machine

```bash
scp ubuntu@<CONTROL_PLANE_PUBLIC_IP>:/etc/kubernetes/admin.conf .
export KUBECONFIG=$(pwd)/admin.conf

# OR mkdir $HOME/.kube
# cp $(pwd)/admin.conf $HOME/.kube/config

```
