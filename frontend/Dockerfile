# Stage 1: Build
FROM node:24-alpine AS build
WORKDIR /app
# для кеширования зависимостей
COPY package*.json ./
RUN npm install

# копируем все файлы и собираем проект
COPY . .
RUN npm run build

# Stage 2: Production
FROM nginx:stable-alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]