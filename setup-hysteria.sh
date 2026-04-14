#!/bin/bash

#установка пакетов
apt update
apt install -y openssl qrencode

# ==== Загружаем переменные из .env ====
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "Ошибка: Файл .env не найден!"
    exit 1
fi

# Проверка DOMAIN
if [ -z "$DOMAIN" ]; then
    echo "Ошибка: DOMAIN не задан в .env"
    exit 1
fi

if [ -f hysteria_passwords.env ]; then
    export $(grep -v '^#' hysteria_passwords.env | xargs)
else
    echo "Файл hysteria_passwords.env не найден, генерируем новые пароли..."
    # Генерация паролей
    HYSTERIA_PASSWORD=$(openssl rand -hex 16)
    OBFS_PASSWORD=$(openssl rand -hex 16)

    # Сохранение в файл
    cat <<EOF > hysteria_passwords.env
# время генерации: $(date)
HYSTERIA_PASSWORD=${HYSTERIA_PASSWORD}
OBFS_PASSWORD=${OBFS_PASSWORD}
EOF

fi


# Создаем конфиг
cat <<EOF > hysteria.yaml
listen: :443

bandwidth:
  up: 0 mbps
  down: 0 mbps

transport:
  congestion:
    type: ${HYSTERIA_CONGESTION_CONTROL:-brutal}

quic:
  initStreamReceiveWindow: 8388608
  maxStreamReceiveWindow: 8388608
  initConnReceiveWindow: 20971520
  maxConnReceiveWindow: 20971520
  maxIdleTimeout: 30s
  maxIncomingStreams: 1024
  disablePathMTUDiscovery: false

logging:
  level: warn

# TLS
tls:
  cert: /etc/nginx/certs/${DOMAIN}.crt
  key: /etc/nginx/certs/${DOMAIN}.key
  sniGuard: strict

# Auth
auth:
  type: password
  password: ${HYSTERIA_PASSWORD}

# Masquerade (под сайт)
masquerade:
  type: proxy
  proxy:
    url: https://${DOMAIN}
    rewriteHost: true
EOF

# Добавляем obfs если включен
if [ "$HYSTERIA_OBFS" = "true" ]; then
cat <<EOF >> hysteria.yaml

# Obfuscation
obfs:
  type: salamander
  salamander:
    password: ${OBFS_PASSWORD}
EOF
fi

# Генерация client config
client_config="hysteria2://${HYSTERIA_PASSWORD}@${DOMAIN}:443?sni=${DOMAIN}&insecure=0"

if [ "$HYSTERIA_OBFS" = "true" ]; then
    client_config="${client_config}&obfs=salamander&obfs-password=${OBFS_PASSWORD}"
fi

client_config="${client_config}#${SERVER_NAME:-${DOMAIN}}-hysteria2"

# Сохраняем клиентский конфиг
echo "$client_config" > hysteria_client_config.txt

# Вывод
echo "===================================="
echo "Hysteria2 config создан:"
echo " - hysteria.yaml"
echo " - hysteria_client_config.txt"
echo ""
echo "Client URL:"
echo "$client_config"
echo "===================================="
echo "qr код для клиента:"
echo "$client_config" | qrencode -o - -t UTF8
echo "===================================="