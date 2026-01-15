# nginx-reverse-proxy_Xray config

[Fake mock site repo](https://github.com/Radma123/react-content-base)


### Setup
__install docker first !__
1. `git clone <repo_url>`
2. `cp example.env .env` (enter your domain)
3. `chmod +x setup-nginx.sh deploy.sh`
4. `sudo ./deploy.sh`
5. install x-ui panel `bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)`
6.
- enter the panel and install certs from: 
- Certificate /fakesite/nginx/certs/(youdomain).crt
- Private Key /fakesite/nginx/certs/(youdomain).key
- enter (yourdomain) in x-ui panel settings
8. Create grpc inbound with a reverse proxy configuration. service name: api, external proxy: tls, (yourdomain), 443, listen: 0.0.0.0


> [!IMPORTANT]
> `ip addr show docker0`
> ip of docker bridge: 172.17.0.1




> [!WARNING]
> OLD reverse proxy into xray config down below

- root@1314874:/etc/nginx/sites-available# nano default
- root@1314874:/etc/nginx/sites-available# nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
- root@1314874:/etc/nginx/sites-available# systemctl restart nginx

```
# Перенаправление HTTP на HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name mizuoka.mooo.com;
    return 301 https://$host$request_uri;
}

# Основной сервер: Слушает 443, обрабатывает TLS и маршрутизирует трафик
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2; 

    server_name mizuoka.mooo.com;

    # 1. Настройка SSL/TLS (Сертификаты)
    ssl_certificate /root/cert/cert.crt;
    ssl_certificate_key /root/cert/private.key;

    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:10m;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384';
    ssl_prefer_server_ciphers off;

    # 2. ОБРАБОТКА VLESS GRPC (ПУТЬ /api)
    location /api {
        # Проверяем, что Content-Type является gRPC (для маскировки)
        if ($content_type !~ "application/grpc") {
            return 404; # Отклоняем не-gRPC трафик на этом пути
        }

        # Настройки для потоковой передачи
        client_max_body_size 0;
        client_body_timeout 1071906480m;

        # Проксирование на Xray (на внутреннем порту 4443)
        grpc_set_header X-Real-IP $remote_addr;
        grpc_pass grpc://127.0.0.1:4443;
    }

    # 3. ОБРАБОТКА ОБЫЧНОГО HTTP (ЗАГЛУШКА)
    location / {
        root /var/www/html;
        index index.html;
        try_files $uri $uri/ =404;
    }
}
```
