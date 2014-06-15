# nginx site config - managed by puppet

# Ghost instance running try-mts.com
server {
    access_log /var/log/nginx/try-mts.com.log;

    server_name try-mts.com www.try-mts.com;

    # Reverse proxy everything to the node instance
    location / {
        proxy_set_header   X-Real-IP $remote_addr;
        proxy_set_header   Host      $http_host;
        proxy_pass         http://127.0.0.1:10330;
    }

}
