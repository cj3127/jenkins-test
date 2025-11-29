# 基于Harbor的nginx:latest镜像（避免外网拉取）
FROM 192.168.121.106/library/nginx:latest
# 替换欢迎页（复用之前的ConfigMap内容，也可直接复制）
COPY index.html /usr/share/nginx/html/index.html
