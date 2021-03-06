upstream sn-curtain-staging {
  server frontend-staging:80;
}

server {
  # Genaral Setting
  listen 80;
  listen [::]:80;
  server_name dev.sn-curtain.com www.dev.sn-curtain.com;

  
  # Redirect
  return 301 https://dev.sn-curtain.com$request_uri;
}

server {
  # Genaral Setting
  listen 443 ssl;
  listen [::]:443 ssl;
  server_name dev.sn-curtain.com;

  # SSL Setting
  ssl_certificate /etc/nginx/ssl/sn-curtain.com.crt;
  ssl_certificate_key /etc/nginx/ssl/sn-curtain.com.key;
  # ssl_certificate /etc/nginx/ssl/sn-curtain.com.chained.crt;
  # ssl_certificate_key /etc/nginx/ssl/sn-curtain.com.key;
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
  ssl_prefer_server_ciphers on;
  ssl_ciphers AES256+EECDH:AES256+EDH:!aNULL;

  # Directory Setting
  # root /var/www/dev.sn-curtain.com/html;
  access_log /var/www/dev.sn-curtain.com/log/nginx.access.log;
  error_log /var/www/dev.sn-curtain.com/log/nginx.error.log info;

  location / {
    try_files $uri $uri/ @location;
  }

  location @location {
    
    proxy_pass http://sn-curtain-staging;
    proxy_cache STATIC;
    proxy_cache_valid  200 302  60m;
    proxy_cache_valid  404      1m;
    proxy_buffering on;
    proxy_redirect off;
    proxy_http_version 1.1;
    proxy_set_header X-Forwarded-Proto https;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;

    
    # add Strict-Transport-Security to prevent man in the middle attacks
    add_header Strict-Transport-Security "max-age=31536000" always;
  }
}
