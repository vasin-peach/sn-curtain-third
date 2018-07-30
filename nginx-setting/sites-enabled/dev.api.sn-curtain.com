server {
  # Genaral Setting
  listen 80;
  listen [::]:80;
  listen 443 ssl;
  listen [::]:443 ssl;
  server_name dev.api.sn-curtain.com;
  return 301 https://$server_name$request_uri;

  # SSL Setting
  ssl_certificate /etc/nginx/ssl/sn-curtain.com.crt;
  ssl_certificate_key /etc/nginx/ssl/sn-curtain.com.key;
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
  ssl_prefer_server_ciphers on;
  ssl_ciphers AES256+EECDH:AES256+EDH:!aNULL;

  location / {
    proxy_set_header X-Forwarded-Proto https;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;

    proxy_pass http://localhost:5601;
  }
}