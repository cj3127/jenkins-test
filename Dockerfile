# 基于Harbor的nginx:latest镜像
FROM harbor.test.com/library/nginx:latest
COPY index.html /usr/share/nginx/html/index.html
