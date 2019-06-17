# Generate hostname for nginx config
HOST=$(hostname)
NGINX_HOME='/opt/local/etc/nginx/'

# Config hostname in nginx config
gsed -i "s:__HOSTNAME__:${HOST}:g" \
	${NGINX_HOME}nginx.conf

# Enable nginx
svcadm enable svc:/pkgsrc/nginx:default
