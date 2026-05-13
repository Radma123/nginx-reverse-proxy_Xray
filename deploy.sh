#!/bin/bash

# 1. Генерация конфига
chmod +x setup-nginx.sh
./setup-nginx.sh


if [ -f .env ]; then
    export $(cat .env | xargs)
else
    echo "Ошибка: Файл .env не найден!"
fi
# 2. Запуск сборки
docker compose up -d --build --remove-orphans

echo "⏳ Ожидаем генерацию SSL (около 30 секунд)..."
sleep 10

# 3. Проверка логов SSL-компаньона
if docker logs nginx-proxy-acme 2>&1 | grep -q "Challenge is valid"; then
    echo "✅ SSL сертификат успешно получен!"
else
    echo "ℹ️ Проверка SSL еще в процессе или возникла задержка. Проверь 'docker logs nginx-proxy-acme'"
fi

# 4. Чистка старых образов
docker image prune -f

echo "🚀 Сайт доступен по адресу: https://${DOMAIN}"
