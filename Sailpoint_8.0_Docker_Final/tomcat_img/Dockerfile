FROM centos

MAINTAINER parag.acharyya@tcs.com


#Install wget utility for CentOS for downloading JDK, Tomcat & MySQL
RUN yum install -y -q wget

#Install required packages for CentOS
RUN yum install -y -q net-tools
RUN yum install -y -q telnet
RUN yum install -y -q iptables-services
RUN yum install -y -q unzip

#Install MySQL Client
RUN yum install -y -q mysql

#Install JAVA and set JAVA_HOME environment variable
RUN mkdir /opt/java/
WORKDIR /opt/java/
COPY jdk-8u291-linux-x64.tar.gz /opt/java/
RUN tar -xf jdk-8u291-linux-x64.tar.gz
ENV JAVA_HOME=/opt/java/jdk1.8.0_291

#Install Tomcat and set CATALINA_HOME environment variable
RUN mkdir /opt/tomcat9/
WORKDIR /opt/tomcat9/
COPY apache-tomcat-9.0.45.tar.gz /opt/tomcat9/
RUN tar -xf apache-tomcat-9.0.45.tar.gz
RUN mv apache-tomcat-9.0.45/* . && rm apache-tomcat-9.0.45.tar.gz && rm -rf apache-tomcat-9.0.45 && pwd && ls -lrtha
ENV CATALINA_HOME=/opt/tomcat9

#Update the PATH environment variable
ENV PATH=$PATH:$JAVA_HOME/bin:$CATALINA_HOME/bin

WORKDIR /opt/tomcat9/
