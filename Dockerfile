# 基于Harbor的nginx:latest镜像
FROM harbor.test.com/library/nginx:18
COPY index.html /usr/share/nginx/html/index.html
