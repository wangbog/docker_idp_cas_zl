# docker_idp_cas_zl
1. 配置宿主机环境(参考https://wiki.carsi.edu.cn/pages/viewpage.action?pageId=1671214)

配置本机IP

修改主机域名 vi /etc/hostname 及 hostname命令

关闭SELinux

开放本机端口（如firewall-cmd）

设置时间同步（NTP配置，IdP必须要求时间同步）

2. 配置Docker环境（如宿主机已安装配置好docker环境，则忽略）

sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

sudo yum -y install -y yum-utils device-mapper-persistent-data lvm2

sudo yum -y install docker-ce docker-ce-cli containerd.io

sudo systemctl start docker

可以用hello-world docker镜像验证一下环境（这一步可以不做）： sudo docker run hello-world

3. 在宿主机上启动IdP的docker

sudo -y install git

git clone https://github.com/carsi-cernet/docker_idp_cas_zl.git

cd docker_idp_cas

docker build --rm -t local/carsi-idp-cas .

docker run -itd -v /opt/shibboleth-idp/:/opt/shibboleth-idp/ -v /etc/localtime:/etc/localtime:ro -v /etc/hostname:/etc/hostname -v /sys/fs/cgroup:/sys/fs/cgroup:ro -p 80:80 -p 443:443 -p 8443:8443 --privileged=true local/carsi-idp-cas

查询container_id:

docker ps -a

进入该镜像的bash环境：

docker exec -it <container_id> /bin/bash

如需停止容器：

docker stop <container_id> - 停止docker daemon

4. 在容器bash内执行

首先确认: hostname命令确认一下域名是否已识别；date命令确认一下时间及时区是否正确。

修改/root/inst/idp3config/autoconfig.sh中的admin_mail为运维管理员的邮箱地址（此处是在Let's Encrypt申请网站证书时使用的）。

sh /root/inst/idp3config/autoconfig.sh  （注意执行中需要输入idp域名，并多次输入证书密码。另外改配置自动回生成Let's Encript 证书。最后重新build的时候需要确认一下安装路径 Installation Directory: [/opt/shibboleth-idp]，此时需要回车确认）

根据本校CAS的实际配置，修改/opt/shibboleth-idp/conf/路径下的 idp.properties 及 attribute-resolver.xml两个文件，修改完毕后重启tomcat：systemctl status tomcat， 重启后访问一下https://<idp域名>/idp/ 应该可以看到“No services are available at this location.”的提示。（备注：本docker容器已自动配置为跳转到智麟提供的测试用CAS服务器，因此理论上这一步不做配置也可以访问通，可先基于此配置验证环境是否妥当，之后再根据本校情况进行修改）

将/opt/shibboleth-idp/metadata/idp-metadata.xml通过CARSI自服务系统上传到联盟（docker容器启动时已与宿主机同步了/opt/shibboleth-idp/路径，因此直接在宿主机中即可找到该文件，具体上传方法参考： https://github.com/carsi-cernet/doc/blob/master/CARSI_IdP%E5%AE%89%E8%A3%85%E9%85%8D%E7%BD%AE%E6%96%87%E6%A1%A3_%E8%AF%A6%E7%BB%86.md#4-%E5%90%91carsi%E8%81%94%E7%9B%9F%E6%8F%90%E4%BA%A4idp%E9%85%8D%E7%BD%AE%E4%BF%A1%E6%81%AF）

sh /root/inst/idp3config/startidp.sh

之后即可在预上线环境中进行测试了（具体参考：https://wiki.carsi.edu.cn/pages/viewpage.action?pageId=2261000， 用户名密码请咨询智麟索取）。
