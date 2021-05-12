FROM tomcatoncentos

#Add IIQ to Tomcat webapps for deployment
COPY identityiq.war /tmp

RUN  mkdir /opt/tomcat9/webapps/identityiq && \
unzip -qq /tmp/identityiq.war -d /opt/tomcat9/webapps/identityiq && \
chmod +x /opt/tomcat9/webapps/identityiq/WEB-INF/bin/iiq && \
rm /tmp/identityiq.war

#Provide appropriate permissions to files
WORKDIR /opt/tomcat9/webapps/identityiq/WEB-INF/classes/
RUN chmod ug+w iiq.properties

WORKDIR /opt/tomcat9/webapps/identityiq/WEB-INF/database/
RUN mv create_identityiq_tables-8.0.mysql create_identityiq_tables8.mysql
RUN chmod +x create_identityiq_tables8.mysql 

#Entrypoint script to configure iiq and run tomcat
COPY entrypoint.sh /opt/entrypoint.sh
RUN chmod +x /opt/entrypoint.sh

WORKDIR /opt/tomcat9

EXPOSE 8080

#Launch entrypoint script which in turn will launch tomcat
CMD ["/opt/entrypoint.sh", "run"]
#CMD ["/opt/tomcat9/apache-tomcat-9.0.45/bin/catalina.sh", "run"]
