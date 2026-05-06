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

location /upload {
    if (\$scheme != "https"){
        return 403;
    }
    
    # Увеличиваем буферы именно для этого пути, если не добавили глобально
    client_body_buffer_size 1m;
    
    proxy_pass http://host.docker.internal:50053;
    
    proxy_http_version 1.1; # XHTTP требует 1.1 или 2.0
    
    # Исправляем заголовки
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    
    # Отключаем буферизацию (жизненно важно для XHTTP/WebSocket/gRPC)
    proxy_buffering off;
    proxy_request_buffering off;
    
    # Убираем ограничение на размер тела (для загрузки файлов через прокси)
    client_max_body_size 0;

    # Таймауты для стабильности соединения
    proxy_read_timeout 1h;
    proxy_send_timeout 1h;
    
    # Поддержка апгрейда соединения (на случай, если XHTTP переключится в WS-like режим)
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection "upgrade";
}

EOF
