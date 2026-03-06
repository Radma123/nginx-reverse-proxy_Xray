#!/bin/bash

# Загружаем переменные из .env
if [ -f .env ]; then
    export $(cat .env | xargs)
else
    echo "Ошибка: Файл .env не найден!"
    exit 1
fi

# Путь к папке конфигов на хосте
VHOST_DIR="/fakesite/nginx/vhost"
mkdir -p $VHOST_DIR

# Создаем конфиг для gRPC и /api
# Мы используем envsubst, чтобы подставить имя домена в название файла
cat <<EOF > "${VHOST_DIR}/${DOMAIN}_location"

# gRPC
location /api {
    if (\$content_type !~ "application/grpc") {
        return 404;
    }

    if (\$scheme != "https"){
        return 403;
    }

    client_max_body_size 0;
    client_body_timeout 1071906480m;

    grpc_set_header Host \$host;
    grpc_set_header X-Real-IP \$remote_addr;

    grpc_pass grpc://host.docker.internal:50051;
}

# WebSocket
location /ws {
    if (\$scheme != "https"){
        return 403;
    }

    proxy_pass http://host.docker.internal:50052;

    proxy_http_version 1.1;

    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection "upgrade";

    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;

    proxy_read_timeout 86400;
}

EOF
