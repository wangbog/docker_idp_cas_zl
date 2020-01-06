cp -f /root/inst/idp3config/metadata-providers.xml /opt/shibboleth-idp/conf/metadata-provider.xml
wget -O /opt/shibboleth-idp/metadata/carsifed-metadata-pre.xml https://www.carsi.edu.cn/carsimetadata/carsifed-metadata.xml
chown -R tomcat.tomcat /opt/shibboleth-idp
systemctl restart httpd
systemctl restart tomcat
