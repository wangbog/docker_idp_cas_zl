source /etc/profile

# config httpd
\cp -f /root/inst/idp3config/httpd.conf /etc/httpd/conf/httpd.conf
\cp -f /root/inst/idp3config/index.html /var/www/html/index.html
\cp -f /root/inst/idp3config/ports.conf /etc/httpd/conf.d/ports.conf
\cp -f /root/inst/idp3config/idp80.conf /etc/httpd/conf.d/idp80.conf
systemctl restart httpd

# config tomcat
\cp -f /root/inst/idp3config/idp.xml /etc/tomcat/Catalina/localhost/idp.xml
\cp -f /root/inst/idp3config/server.xml /etc/tomcat/server.xml
\cp -f /root/inst/idp3config/javax.servlet.jsp.jstl-api-1.2.1.jar /usr/share/tomcat/lib/javax.servlet.jsp.jstl-api-1.2.1.jar
\cp -f /root/inst/idp3config/javax.servlet.jsp.jstl-1.2.1.jar /usr/share/tomcat/lib/javax.servlet.jsp.jstl-1.2.1.jar
systemctl restart tomcat

# config https
hostname=`hostname`
admin_mail="admin@xxx.edu.cn"
certbot certonly --agree-tos --no-eff-email -m $admin_mail -d $hostname --webroot -w /var/www/html
systemctl restart crond
echo "0 0 1 * * certbot renew >/dev/null 2>&1" >> /var/spool/cron/root
\cp -f /root/inst/idp3config/ssl.conf /etc/httpd/conf.d/ssl.conf
\cp -f /root/inst/idp3config/idp.conf /etc/httpd/conf.d/idp.conf
sed -i "s/MY_IDP_HOSTNAME/$hostname/g" /etc/httpd/conf.d/idp.conf
sed -i "s/#Listen 443/Listen 443/g" /etc/httpd/conf.d/ports.conf
systemctl restart httpd

# config idp
rm -rf /root/inst/idp3config/shibboleth-identity-provider-3.4.3/
cd /root/inst/idp3config/
tar xzf shibboleth-identity-provider-3.4.3.tar.gz
sh /root/inst/idp3config/shibboleth-identity-provider-3.4.3/bin/install.sh
sed -i "s/Fill in the details for your IdP here/Fill in the details for your UIM-Z IdP here/g" /opt/shibboleth-idp/metadata/idp-metadata.xml
openssl pkcs12 -in /opt/shibboleth-idp/credentials/idp-backchannel.p12 -out /opt/shibboleth-idp/credentials/idp-backchannel.key -nocerts -nodes
\cp -f /root/inst/idp3config/metadata-providers-pre.xml /opt/shibboleth-idp/conf/metadata-providers.xml
\cp -f /root/inst/idp3config/attribute-resolver.xml /opt/shibboleth-idp/conf/attribute-resolver.xml
salt=`openssl rand 32 -base64`
sed -i "s/xxxxxxxxxxxxxxxxxxxx/$salt/g" /opt/shibboleth-idp/conf/attribute-resolver.xml
\cp -f /root/inst/idp3config/audit.xml /opt/shibboleth-idp/conf/audit.xml
\cp -f /root/inst/idp3config/consent-intercept-config.xml /opt/shibboleth-idp/conf/intercept/consent-intercept-config.xml
\cp -f /root/inst/idp3config/relying-party.xml /opt/shibboleth-idp/conf/relying-party.xml
\cp -f /root/inst/idp3config/attribute-filter.xml /opt/shibboleth-idp/conf/attribute-filter.xml
\cp -f /root/inst/idp3config/dsmeta.pem /opt/shibboleth-idp/credentials/
sed -i "s/#idp.consent.allowPerAttribute = false/idp.consent.allowPerAttribute = true/g" /opt/shibboleth-idp/conf/idp.properties
wget -P /opt/shibboleth-idp/metadata/ https://dspre.carsi.edu.cn/carsifed-metadata-pre.xml
chown -R tomcat.tomcat /opt/shibboleth-idp
systemctl restart httpd
systemctl restart tomcat

# config CAS
mkdir -p /opt/shibboleth-idp/flows/authn/Shibcas/
\cp -f /root/inst/idp3config/shibcas-authn-beans.xml /opt/shibboleth-idp/flows/authn/Shibcas/shibcas-authn-beans.xml
\cp -f /root/inst/idp3config/shibcas-authn-flow.xml /opt/shibboleth-idp/flows/authn/Shibcas/shibcas-authn-flow.xml
\cp -f /root/inst/idp3config/no-conversation-state.jsp /opt/shibboleth-idp/edit-webapp/no-conversation-state.jsp
\cp -f /root/inst/idp3config/shib-cas-authenticator-3.2.3.jar /opt/shibboleth-idp/edit-webapp/WEB-INF/lib/shib-cas-authenticator-3.2.3.jar
\cp -f /root/inst/idp3config/cas-client-core-3.4.1.jar /opt/shibboleth-idp/edit-webapp/WEB-INF/lib/cas-client-core-3.4.1.jar
\cp -f /root/inst/idp3config/web.xml /opt/shibboleth-idp/edit-webapp/WEB-INF/web.xml
sed -i "s/idp.authn.flows=Password/idp.authn.flows=Shibcas/g" /opt/shibboleth-idp/conf/idp.properties
echo "shibcas.casServerUrlPrefix = https://ssoedu.cn" >> /opt/shibboleth-idp/conf/idp.properties
echo 'shibcas.casServerLoginUrl = ${shibcas.casServerUrlPrefix}/login' >> /opt/shibboleth-idp/conf/idp.properties
echo "shibcas.serverName = https://`hostname`" >> /opt/shibboleth-idp/conf/idp.properties
\cp -f /root/inst/idp3config/general-authn.xml /opt/shibboleth-idp/conf/authn/general-authn.xml
\cp -f /root/inst/idp3config/attribute-resolver-cas.xml /opt/shibboleth-idp/conf/attribute-resolver.xml
salt=`openssl rand 32 -base64`
sed -i "s/xxxxxxxxxxxxxxxxxxxx/$salt/g" /opt/shibboleth-idp/conf/attribute-resolver.xml
chown -R tomcat.tomcat /opt/shibboleth-idp
/opt/shibboleth-idp/bin/build.sh
systemctl restart tomcat