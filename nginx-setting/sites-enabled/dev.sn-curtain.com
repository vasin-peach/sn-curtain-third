server {
  # Genaral Setting
  listen 80;
  listen [::]:80;
  listen 443 ssl http2;
  listen [::]:443 ssl http2;
  server_name dev.sn-curtain.com;
  return 301 https://$server_name$request_uri;

  # SSL Setting
  ssl_certificate /etc/nginx/ssl/certificate.crt;
  ssl_certificate_key /etc/nginx/ssl/private.key;
  ssl_protocols SSLv3 TLSv1 TLSv1.1 TLSv1.2;
  ssl_prefer_server_ciphers on;
  ssl_ciphers AES256+EECDH:AES256+EDH:!aNULL;

  # Directory Setting
  root /var/www/dev.sn-curtain.com/html;
  access_log /var/www/dev.sn-curtain.com/log/nginx.access.log;
  error_log /var/www/dev.sn-curtain.com/log/nginx.error.log info;

  location / {
    try_files $uri $uri/ /index.html;

    proxy_set_header        Host $host;
    proxy_set_header        X-Real-IP $remote_addr;
    proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header        X-Forwarded-Proto $scheme;

    # re-write redirects to http as to https, example: /home
    proxy_redirect http:// https://;
  }

  # location / {
  #  proxy_set_header X-Forwarded-Proto https;
  #  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  #  proxy_set_header Host $http_host;
  #  proxy_redirect off;
  #
  #  proxy_pass http://localhost:5502;
  # }
}