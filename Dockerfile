FROM mongo:3.4-jessie

COPY script/initdb.js /entrypoint/

# Dockerfile
ENTRYPOINT ["docker-entrypoint.sh"]
