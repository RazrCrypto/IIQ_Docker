#!/bin/bash

#check environment variables and set some defaults
if [ -z "${MYSQL_HOST}" ]
then
	export MYSQL_HOST=db
fi
if [ -z "${MYSQL_USER}" ]
then
	export MYSQL_USER=root
fi
if [ -z "${MYSQL_PASSWORD}" ]
then
	export MYSQL_PASSWORD=I@mR00t
fi

export MYSQL_PORT=3306
#export HIBERNATE_DIALECT=org.hibernate.dialect.MySQL8Dialect

echo "The MySQL host is : ${MYSQL_HOST}"
echo "The MySQL user is : ${MYSQL_USER}"
echo "The MySQL password is : ${MYSQL_PASSWORD}"
echo "The MySQL ROOT password is : ${MYSQL_ROOT_PASSWORD}"

#wait for database to start
echo "waiting for database on ${MYSQL_HOST} to come up"
#while ! mysqladmin ping -h"${MYSQL_HOST}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" --silent ; do
while ! mysqladmin ping -h"${MYSQL_HOST}" --silent ; do
	echo -ne "."
	sleep 1
done

#check if database schema is already there
export DB_SCHEMA_VERSION=$(mysql -s -N -h"${MYSQL_HOST}" -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "select schema_version from identityiq.spt_database_version;")
if [ -z "$DB_SCHEMA_VERSION" ]
then
	echo "No schema present, creating IIQ schema in DB" 
	
	# create database schema
	schemaFile=/opt/tomcat9/webapps/identityiq/WEB-INF/database/create_identityiq_tables8.mysql

	if [ -e "$schemaFile" ]; then

		if [ -x "$schemaFile" ]; then

			mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" -h"${MYSQL_HOST}" < /opt/tomcat9/webapps/identityiq/WEB-INF/database/create_identityiq_tables8.mysql
			echo "=> Done creating database!"
		else
			ls -lrtha "/opt/tomcat9/webapps/identityiq/WEB-INF/database/"
			echo "=> The IIQ schema creation file doesn't have executable permission"
		fi
	else
		ls -lrtha "/opt/tomcat9/webapps/identityiq/WEB-INF/database/"
		echo "=> The IIQ schema creation file doesn't exist!"
	fi
else
	echo "=> Database already set up, version "$DB_SCHEMA_VERSION" found, starting IIQ directly";
fi

propFile=/opt/tomcat9/webapps/identityiq/WEB-INF/classes/iiq.properties

if [ -e "$propFile" ]; then

	if [ -w "$propFile" ]; then

		sed -ri -e "s/mysql:\/\/localhost/mysql:\/\/${MYSQL_HOST}:${MYSQL_PORT}/" /opt/tomcat9/webapps/identityiq/WEB-INF/classes/iiq.properties
		sed -ri -e "s/dataSource.username\=.*/dataSource.username=${MYSQL_USER}/" /opt/tomcat9/webapps/identityiq/WEB-INF/classes/iiq.properties
		sed -ri -e "s/dataSource.password\=.*/dataSource.password=${MYSQL_PASSWORD}/" /opt/tomcat9/webapps/identityiq/WEB-INF/classes/iiq.properties
		
		#If using MySQL 8.0, uncomment the following 3 lines:
		#sed -ri -e "s/dataSource.driverClassName\=.*/dataSource.driverClassName=com.mysql.cj.jdbc.Driver/" /opt/tomcat9/webapps/identityiq/WEB-INF/classes/iiq.properties
		#sed -ri -e "s/pluginsDataSource.driverClassName\=.*/pluginsDataSource.driverClassName=com.mysql.cj.jdbc.Driver/" /opt/tomcat9/webapps/identityiq/WEB-INF/classes/iiq.properties
		#sed -ri -e "s/sessionFactory.hibernateProperties.hibernate.dialect\=.*/sessionFactory.hibernateProperties.hibernate.dialect=${HIBERNATE_DIALECT}/" /opt/tomcat9/webapps/identityiq/WEB-INF/classes/iiq.properties
		
		echo "=> Done configuring iiq.properties!"
	else
		ls -lrtha "/opt/tomcat9/webapps/identityiq/WEB-INF/classes/"
		echo "=> The IIQ properties file doesn't have write permission!"
	fi
else
	ls -lrtha "/opt/tomcat9/webapps/identityiq/WEB-INF/classes/"
	echo "=> The IIQ properties file doesn't exist!"
fi

export DB_SPADMIN_PRESENT=$(mysql -s -N -h"${MYSQL_HOST}" -uroot -p${MYSQL_ROOT_PASSWORD} -e "select name from identityiq.spt_identity where name='spadmin';")
if [ -z $DB_SPADMIN_PRESENT ]
then
	echo "No spadmin user in database, setting up database connection in iiq.properties and importing init.xml and init-lcm.xml"

	iiqExecFile=/opt/tomcat9/webapps/identityiq/WEB-INF/bin/iiq
	if [ -x "$iiqExecFile" ]; then

		echo "import init.xml" | /opt/tomcat9/webapps/identityiq/WEB-INF/bin/iiq console
		echo "import init-lcm.xml" | /opt/tomcat9/webapps/identityiq/WEB-INF/bin/iiq console
		echo "=> Done loading init.xml & init-lcm.xml via iiq console!"
	else
		ls -lrtha "/opt/tomcat9/webapps/identityiq/WEB-INF/bin/"
		echo "=> The iiq file either doesn't exist or doesn't have executable permission!"
	fi
fi

#Run Tomcat server
/opt/tomcat9/bin/catalina.sh run
