
echo "show nfs mount"
df -h | grep nfs

echo "start jupyter"
docker compose -f docker-compose-jupyterlab.yml up -d
