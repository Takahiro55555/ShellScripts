#! /bin/bash

## 参考サイト
## Ubuntu 18.04 LTS にDocker環境をインストールする
##   https://qiita.com/soumi/items/5b01d88c187b678c0474
## 
## Ubuntu 18.04 LTS にKubernetes環境をインストールする [Master / Worker]
##   https://qiita.com/soumi/items/7736ac3aabbbe4fb474a

## Docker, k8sをインストール
chmod +x setupK8sCommon.sh
./setupK8sCommon.sh

## k8sをセットアップ
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# 以下の3行は上記のコマンドを実行した際に表示されたものをそのままコピペ
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

sudo sysctl net.bridge.bridge-nf-call-iptables=1

## flannelを入れる
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml