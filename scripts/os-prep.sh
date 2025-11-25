ssh -i <SSH_KEY_PATH> ubuntu@<PRIVATE_IP_ADDRESS>

# 2. Update & install dependencies
sudo apt update && sudo apt -y upgrade
sudo apt -y install apt-transport-https ca-certificates curl gnupg lsb-release

# 3. Disable swap (kubelet requires swap off)
sudo swapoff -a
# To make persistent:
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# 4. Load kernel modules & sysctl for k8s networking (run as root)
cat <<'EOF' | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
overlay
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<'EOF' | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system