FROM nginx:latest

COPY ./volumes/ /tmp/nginx/

ENTRYPOINT ["/bin/bash", "/tmp/nginx/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]