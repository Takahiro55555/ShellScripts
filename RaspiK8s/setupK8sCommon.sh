#! /bin/bash

## 参考サイト
## Ubuntu 18.04 LTS にDocker環境をインストールする
##   https://qiita.com/soumi/items/5b01d88c187b678c0474
## 
## Ubuntu 18.04 LTS にKubernetes環境をインストールする [Master / Worker]
##   https://qiita.com/soumi/items/7736ac3aabbbe4fb474a
##
##
## OSバージョン
##   Ubuntu 19.10 (Eoan Ermine)

sudo apt update
sudo apt -y upgrade

## Dockerのインストール
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88

# Ubuntu 19.04（Disco）のリポジトリにしないとインストールできなかった
sudo add-apt-repository \
   "deb [arch=arm64] https://download.docker.com/linux/ubuntu \
   disco \
   stable"

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

## k8sのインストール
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"

sudo apt update

sudo apt install -y kubeadm
sudo swapoff -a