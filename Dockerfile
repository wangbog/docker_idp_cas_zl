FROM centos:7.2.1511
ENV container docker
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]

RUN yum -y install httpd; \
rm -f /etc/httpd/conf.d/welcome.conf; \
rm -f /etc/httpd/conf.d/autoindex.conf; \
yum -y install mod_ssl java-1.8.0-openjdk java-1.8.0-openjdk-devel; \
yum -y install tomcat wget; \
echo "" >> /etc/profile; \
echo "export JAVA_HOME=/etc/alternatives/java_sdk_1.8.0" >> /etc/profile; \
echo "export PATH=$PATH:$JAVA_HOME/bin" >> /etc/profile; \
echo "export CLASSPATH=.:$JAVA_HOME/jre/lib:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar" >> /etc/profile; \
source /etc/profile; \
yum -y install epel-release; \
yum --enablerepo=epel -y install certbot; \
yum -y install crontabs; \
sed -i '/session    required   pam_loginuid.so/c\#session    required   pam_loginuid.so' /etc/pam.d/crond;

COPY idp3config /root/inst/idp3config/
