wget -O /opt/shibboleth-idp/metadata/carsifed-metadata-pre.xml https://dspre.carsi.edu.cn/carsifed-metadata-pre.xml
chown -R tomcat.tomcat /opt/shibboleth-idp
systemctl restart httpd
systemctl restart tomcat
