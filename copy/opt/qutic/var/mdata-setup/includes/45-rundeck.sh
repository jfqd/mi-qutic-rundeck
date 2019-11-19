
if mdata-get project_name 1>/dev/null 2>&1; then
  PROJECT_NAME=`mdata-get project_name`

  if mdata-get resources_xml 1>/dev/null 2>&1; then
    RESOURCES_XML=`mdata-get resources_xml`
    mkdir -p "/opt/rundeck/projects/${PROJECT_NAME}/etc/"
    curl -s -L "${RESOURCES_XML}" > "/opt/rundeck/projects/${PROJECT_NAME}/etc/resources.xml"
  fi

fi