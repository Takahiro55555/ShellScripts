## Raspberry Pi k8s Cluster

### ***はじめに***
このREADMEは自分のための備忘録的な物です。参考にする際は自己責任でお願いします。

### ***環境***

| | |
|---|---|
|マシン |Raspberry Pi 4 Model B 4GB |
|マシン数 | 3 |
|OS |[Ubuntu Server 19.10.1](https://wiki.ubuntu.com/ARM/RaspberryPi) |
|ストレージ |microSD 32GB |
| | |

### ***1. 下準備***

#### 1.1 vimの設定（任意）

```
$ ./setupVim.sh
$ sudo ./setupVim.sh
```

#### 1.2 ホスト名の変更
以下のコマンドを実行してホスト名を編集する。ホスト名は重複しないようにすること。

```
$ sudo vi /etc/hostname
```

#### 1.3 cgroupのmemoryを有効化
後に`sudo kubeadm init [略]`や`kubeadm join [略]`のようなコマンドを実行する際に以下のようなエラーが起こった。

```
[略]
CGROUPS_MEMORY: missing
error execution phase preflight: [preflight] Some fatal errors occurred:
        [ERROR SystemVerification]: missing cgroups: memory
[preflight] If you know what you are doing, you can make a check 
[略]
```

そこで、[この記事](https://kuromt.hatenablog.com/entry/2019/01/03/233347)を参考に設定。

> cgroupのmemoryが無効化されているらしい。`/proc/cgroups`を確認するとたしかにmemoryのenabledが0（無効）になっている。
>
> ```
> $ cat /proc/cgroups 
> #subsys_name    hierarchy   num_cgroups enabled
> cpuset  10  2   1
> cpu 6   60  1
> cpuacct 6   60  1
> blkio   7   60  1
> memory  0   68  0
> devices 4   60  1
> freezer 2   2   1
> net_cls 3   2   1
> perf_event  5   2   1
> net_prio    3   2   1
> pids    8   66  1
> rdma    9   1   1
> ```
>
> boot時の設定を変更してcgroupfsのmemoryを有効にする。
> `/boot/firmware/cmdline.txt`に`cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory`を追記して再起動する。追記が終わったあとのファイルは以下の通り。

上記の記事では、`/boot/firmware/cmdline.txt`を編集していたが、見つからなかったため同様の内容が記述されているファイル(`/boot/firmware/nobtcmd.txt`)の末尾(改行はしない)に`cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory`を追加し、再起動した。

```
$ sudo vi sudo vi /boot/firmware/nobtcmd.txt
$ sudo reboot
```

### ***2. インストールと設定***
[この記事](https://qiita.com/soumi/items/7736ac3aabbbe4fb474a)と[こちらの記事](https://qiita.com/soumi/items/5b01d88c187b678c0474)を参考に設定を行った。

#### 1.1 Master側のインストール・設定
Masterとなるマシンを1台選び、本ディレクトリ内にあるスクリプトを以下のように実行する。

```
$ chmod +x setupK8sMaster.sh
$ ./setupK8sMaster.sh
[略]
Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.11.66:6443 --token xxxxxx.xxxxxxxxxxxxxxxx \
    --discovery-token-ca-cert-hash sha256:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
[略]
$ kubectl get nodes # 以下の例のように表示されればとりあえずOK(細かい数字は気にしない)
NAME      STATUS     ROLES    AGE     VERSION
pi4b-01   NotReady   master   3m46s   v1.17.2
```

##### 補足
上記で実行したスクリプトではまず、`setupK8sCommon.sh`というスクリプトファイルを実行する。そこには以下のような記述がある。

```
sudo add-apt-repository \
   "deb [arch=arm64] https://download.docker.com/linux/ubuntu \
   disco \
   stable"
```

元々、`disco`の部分は`$(lsb_release -cs)`となっていたが、[Dockerの公式ドキュメント](https://docs.docker.com/install/linux/docker-ce/ubuntu/)を見ると、

> ### OS requirements
> To install Docker Engine - Community, you need the 64-bit version of one of these Ubuntu versions:
> - Disco 19.04
> - Cosmic 18.10
> - Bionic 18.04 (LTS)
> - Xenial 16.04 (LTS)

となっており、今回使用しているOSのバージョン(19.10)には対応していないようである。
また、実際に元のまま実行してもdockerのインストールを行うことができなかった。

そこで、`$(lsb_release -cs) \`を`disco \`と書き換えた。

なお、この対応が正しいかどうかは分からない。

（※）上記の情報は2020-01-23現在のものです。

#### 1.2 Worker側のインストール・設定
Workerとなるマシン（1台以上）で本ディレクトリ内にあるスクリプトを以下のように実行する。

```
$ ./setupK8sCommon.sh
```

Master側のインストール・設定を行った際に表示された以下のようなコマンドを実行する。

```
$ sudo kubeadm join 192.168.11.66:6443 --token xxxxxx.xxxxxxxxxxxxxxxx \
    --discovery-token-ca-cert-hash sha256:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

なお、[参考記事](https://qiita.com/soumi/items/7736ac3aabbbe4fb474a#w-master%E3%83%8E%E3%83%BC%E3%83%89%E3%81%ABjoin%E3%81%99%E3%82%8B)によると、Masterの起動から超時間経過した場合、上記のトークンは無効になるようである。

トークンが無効になってしまった場合、以下のコマンドを実行し再取得できるようである。

```
$ kubeadm token create
```

#### 1.3 確認
以下のコマンドを実行し、Workerノードの参加を確認する。

```
$ kubectl get nodes
NAME      STATUS     ROLES    AGE   VERSION
pi4b-01   Ready      master   30m   v1.17.2
pi4b-02   Ready      <none>   10m   v1.17.2
pi4b-03   NotReady   <none>   23s   v1.17.2
```
上記の実行例では、`STATUS`が`NotReady`となっているが、しばらく待って再度`kubectl get nodes`を実行すると、`Ready`に変化していた。

#### 1.4 Dashboardをインストール
リンク切れにより[参考記事](https://qiita.com/soumi/items/7736ac3aabbbe4fb474a#m-dashboard%E3%82%92%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%88%E3%83%BC%E3%83%AB%E3%81%8A%E3%81%BE%E3%81%91)のとおりには出来なかった。

後日余裕があるときに設定したい。

(以下、Comming Soon...)
