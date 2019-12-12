#!/bin/sh

sudo su -c 'echo http://dl-cdn.alpinelinux.org/alpine/edge/main/ >> /etc/apk/repositories'
sudo su -c 'echo https://danmolik.com/alpine/ >> /etc/apk/repositories'
sudo su -c 'wget https://danmolik.com/alpine/alpine-devel@danmolik.com.rsa.pub -P /etc/apk/keys'
sudo apk update
sudo apk del linux-virt
sudo apk --no-cache add linux-hyperspike
sudo apk --no-cache add util-linux conmon
sudo apk --no-cache add socat ethtool ipvsadm iproute2 iptables ebtables
sudo apk --no-cache upgrade

sudo apk --no-cache add kubectl kubeadm kubelet cri-o crun crictl ca-certificates ipset
sudo rm -rf /var/cache/apk/*
#sudo mount -t tmpfs cgroup_root /sys/fs/cgroup
#for d in cpuset memory cpu cpuacct blkio devices freezer net_cls perf_event net_prio hugetlb pids; do
#	sudo mkdir /sys/fs/cgroup/$d
#	sudo mount -t cgroup $d -o $d /sys/fs/cgroup/$d
#done
# sudo sed -i -e 's/^#\?\(rc_controller_cgroups=\).*/\1"YES"/' /etc/rc.conf
sudo sed -i -e 's/^#\?\(rc_logger\)\=.*/\1\="YES"/' /etc/rc.conf
sudo sed -i -e 's/^#\?\(rc_parallel\)\=.*/\1\="YES"/' /etc/rc.conf
sudo rc-update add cgroups sysinit
sudo rc-service cgroups start
sudo su -c 'echo "bpffs                      /sys/fs/bpf             bpf     defaults 0 0" >> /etc/fstab'
# sudo su -c 'echo "  ip link set dev eth0 mtu 9001" >> /etc/network/interfaces'
sudo su -c 'echo br_netfilter >> /etc/modules'

sudo su -c 'echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf'
sudo su -c 'echo "net.ipv4.ip_local_port_range=1024 65000" >> /etc/sysctl.conf'
sudo su -c 'echo "net.ipv4.tcp_tw_reuse=1" >> /etc/sysctl.conf'
sudo su -c 'echo "net.ipv4.tcp_fin_timeout=15" >> /etc/sysctl.conf'
sudo su -c 'echo "net.core.somaxconn=4096" >> /etc/sysctl.conf'
sudo su -c 'echo "net.core.netdev_max_backlog=4096" >> /etc/sysctl.conf'
sudo su -c 'echo "net.core.rmem_max=16777216" >> /etc/sysctl.conf'
sudo su -c 'echo "net.core.wmem_max=16777216" >> /etc/sysctl.conf'
sudo su -c 'echo "net.ipv4.tcp_max_syn_backlog=20480" >> /etc/sysctl.conf'
sudo su -c 'echo "net.ipv4.tcp_max_tw_buckets=400000" >> /etc/sysctl.conf'
sudo su -c 'echo "net.ipv4.tcp_no_metrics_save=1" >> /etc/sysctl.conf'
sudo su -c 'echo "net.ipv4.tcp_rmem=4096 87380 16777216" >> /etc/sysctl.conf'
sudo su -c 'echo "net.ipv4.tcp_syn_retries=2" >> /etc/sysctl.conf'
sudo su -c 'echo "net.ipv4.tcp_synack_retries=2" >> /etc/sysctl.conf'
sudo su -c 'echo "net.ipv4.tcp_wmem=4096 65536 16777216" >> /etc/sysctl.conf'
sudo su -c 'echo "#vm.min_free_kbytes=65536" >> /etc/sysctl.conf'
sudo su -c 'echo "net.netfilter.nf_conntrack_max=262144" >> /etc/sysctl.conf'
sudo su -c 'echo "net.ipv4.netfilter.ip_conntrack_generic_timeout=120" >> /etc/sysctl.conf'
sudo su -c 'echo "net.netfilter.nf_conntrack_tcp_timeout_established=86400" >> /etc/sysctl.conf'
sudo su -c 'echo "net.ipv4.neigh.default.gc_thresh1=8096" >> /etc/sysctl.conf'
sudo su -c 'echo "net.ipv4.neigh.default.gc_thresh2=12288" >> /etc/sysctl.conf'
sudo su -c 'echo "net.ipv4.neigh.default.gc_thresh3=16384" >> /etc/sysctl.conf'

sudo mkdir -p /etc/cni/net.d
sudo mkdir -p /opt/cni/bin
sudo su -c 'echo "runtime-endpoint: unix:///var/run/crio/crio.sock" >> /etc/crictl.yaml'
sudo cp /tmp/crio.conf /etc/crio/crio.conf
sudo mkdir /etc/containers
sudo cp /tmp/policy.json /etc/containers
sudo rm -rfv /tmp/*
sudo rm -rfv /var/tmp/*
sudo rc-service crio start
sudo rc-update add crio default
sudo kubeadm config images pull
#sudo cat /var/log/crio/crio.log
#sudo crictl -i /run/crio/crio.sock pull calico/cni:v3.9.1
#sudo crictl -i /run/crio/crio.sock pull calico/node:v3.9.1
#sudo crictl pull docker.io/cilium/operator:v1.6.4
sudo crictl pull docker.io/cilium/cilium:v1.6.4
#sudo crictl -i /run/containerd/containerd.sock pull gcr.io/google-containers/startup-script:v1

sudo rc-update add kubelet default
#df -h
#sudo su -c 'find / -maxdepth 1 -mindepth 1 -type d | xargs du -sh'
#sudo su -c 'find /usr -maxdepth 1 -mindepth 1 -type d | xargs du -sh'
#sudo su -c 'find /usr/bin -maxdepth 1 -mindepth 1 -type d | xargs du -sh'
#ls -lhSr /usr/bin
sudo rm /var/lib/cloud/.bootstrap-complete
