upstream api-stag {
  server sn-curtain.com-api-staging:5000;
}

server {
  # Genaral Setting
  listen 80;
  listen [::]:80;
  listen 443 ssl;
  listen [::]:443 ssl;
  server_name dev.api.sn-curtain.com;
  if ($http_x_forwarded_proto = "http") {
    return 301 https://dev.api.sn-curtain.com$request_uri;
  }

  # SSL Setting
  ssl_certificate /etc/nginx/ssl/sn-curtain.com.crt;
  ssl_certificate_key /etc/nginx/ssl/sn-curtain.com.key;
  ssl_certificate /etc/nginx/ssl/sn-curtain.com.chained.crt;
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
  ssl_prefer_server_ciphers on;
  ssl_ciphers AES256+EECDH:AES256+EDH:!aNULL;

  location / {
    proxy_set_header X-Forwarded-Proto https;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;
    proxy_pass http://api-stag;
    
    # add Strict-Transport-Security to prevent man in the middle attacks
    add_header Strict-Transport-Security "max-age=31536000" always;
  }
}