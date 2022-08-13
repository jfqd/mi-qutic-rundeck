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
      -e "s/dataSource.dbCreate = none/# dataSource.dbCreate = none/" \
       /opt/rundeck/rundeck-config.properties
  
  # https://docs.rundeck.digitalstacks.net/l/en/database/using-my-sql-as-a-database-backend
  cat >> /opt/rundeck/rundeck-config.properties << EOF

# mysql settings
dataSource.dbCreate = update
dataSource.driverClassName = org.mariadb.jdbc.Driver
dataSource.url = jdbc:mysql://${MYSQL_HOST}/${MYSQL_DB}?autoReconnect=true&useSSL=false
dataSource.username = ${MYSQL_USER}
dataSource.password = ${MYSQL_PWD}
EOF
  chmod 0640 /opt/rundeck/rundeck-config.properties
  chown rundeck:rundeck /opt/rundeck/rundeck-config.properties
fi

if mdata-get mail_smarthost 1>/dev/null 2>&1; then
  MAIL_HOST=$(mdata-get mail_smarthost)
  MAIL_FROM=$(mdata-get mail_adminaddr)
  MAIL_USER=$(mdata-get mail_auth_user)
  MAIL_PWD=$(mdata-get mail_auth_user)

  # https://docs.rundeck.digitalstacks.net/l/en/configuration/email-settings
  cat >> /opt/rundeck/rundeck-config.properties << EOF

# mail config
grails.mail.default.from=${MAIL_FROM}
grails.mail.host=${MAIL_HOST}
grails.mail.port=587
grails.mail.username=${MAIL_USER}
grails.mail.password=${MAIL_PWD}
grails.mail.props.mail.smtp.starttls.enable=true
grails.mail.props.mail.smtp.port=587
grails.mail.props.mail.smtp.auth=true
EOF
  chmod 0640 /opt/rundeck/rundeck-config.properties
  chown rundeck:rundeck /opt/rundeck/rundeck-config.properties
fi

if mdata-get snmp_auth 1>/dev/null 2>&1; then
  SNMP_AUTH=$(mdata-get snmp_auth)
  sed -i \
      -e "s/securepwd/${SNMP_AUTH}/" \
       /opt/rundeck/.snmp/snmp.conf
fi

HOSTNAME=$(hostname)
sed -i \
    -e "s/http://localhost:4440/#https://${HOSTNAME}/" \
     /opt/rundeck/rundeck-config.properties

if mdata-get rundeck_adm_user 1>/dev/null 2>&1; then
  ADM_USER=$(mdata-get rundeck_adm_user)
  ADM_USER=$(mdata-get rundeck_adm_pwd)

  cat > /opt/rundeck/realm.properties << EOF
#
# This file defines users passwords and roles for a HashUserRealm
#
# The format is
#  <username>: <password>[,<rolename> ...]
#
# Passwords may be clear text, obfuscated or checksummed.  The class 
# org.mortbay.util.Password should be used to generate obfuscated
# passwords or password checksums
#
# This sets the temporary user accounts for the Rundeck app
#
# admin:admin,user,admin
${ADM_USER}: ${ADM_USER},user,admin
# user: secure-password

#
# example users matching the example aclpolicy template roles
#
#project-admin:admin,user,project_admin
#job-runner:admin,user,job_runner
#job-writer:admin,user,job_writer
#job-reader:admin,user,job_reader
#job-viewer:admin,user,job_viewer
EOF

fi

root_authorized_keys