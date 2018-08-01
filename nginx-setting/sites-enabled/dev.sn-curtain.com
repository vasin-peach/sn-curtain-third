upstream sn-curtain-staging {
  server frontend-staging;
}

server {
  # Genaral Setting
  listen 80;
  listen [::]:80;
  listen 443 http2 ssl;
  listen [::]:443 http2 ssl;
  server_name dev.sn-curtain.com;

  # SSL Setting
  ssl_certificate /etc/nginx/ssl/sn-curtain.com.crt;
  ssl_certificate_key /etc/nginx/ssl/sn-curtain.com.key;
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
  ssl_prefer_server_ciphers on;
  ssl_ciphers AES256+EECDH:AES256+EDH:!aNULL;

  # # Directory Setting
  # root /var/www/dev.sn-curtain.com/html;
  access_log /var/www/dev.sn-curtain.com/log/nginx.access.log;
  error_log /var/www/dev.sn-curtain.com/log/nginx.error.log info;

  location / {
    proxy_set_header X-Forwarded-Proto https;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;
    proxy_pass https://sn-curtain-staging;
  }
}