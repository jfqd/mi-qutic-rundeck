
if mdata-get project_name 1>/dev/null 2>&1; then
  PROJECT_NAME=`mdata-get project_name`

  if mdata-get resources_xml 1>/dev/null 2>&1; then
    RESOURCES_XML=`mdata-get resources_xml`
    mkdir -p "/opt/rundeck/projects/${PROJECT_NAME}/etc/"
    curl -s -L "${RESOURCES_XML}" > "/opt/rundeck/projects/${PROJECT_NAME}/etc/resources.xml"
  fi
fi

if mdata-get mysql_host 1>/dev/null 2>&1; then
  MYSQL_HOST=`mdata-get mysql_host`
  MYSQL_DB=`mdata-get mysql_database`
  MYSQL_USER=`mdata-get mysql_user`
  MYSQL_PWD=`mdata-get mysql_passwd`
  
  sed -i \
      -e "s/dataSource.url/# dataSource.url/" \
       /opt/rundeck/server/config/rundeck-config.properties
  
  cat >> /opt/rundeck/server/config/rundeck-config.properties << EOF

# mysql settings  
dataSource.driverClassName = com.mysql.jdbc.Driver
dataSource.url = jdbc:mysql://${MYSQL_HOST}/${MYSQL_DB}?autoReconnect=true&useSSL=false
dataSource.username = ${MYSQL_USER}
dataSource.password = ${MYSQL_PWD}
EOF
  chmod 0640 /opt/rundeck/server/config/rundeck-config.properties
  chown rundeck:rundeck /opt/rundeck/server/config/rundeck-config.properties

fi

if mdata-get snmp_auth 1>/dev/null 2>&1; then
  SNMP_AUTH=$(mdata-get snmp_auth)
  sed -i \
      -e "s/securepwd/${SNMP_AUTH}/" \
       /opt/rundeck/.snmp/snmp.conf
fi