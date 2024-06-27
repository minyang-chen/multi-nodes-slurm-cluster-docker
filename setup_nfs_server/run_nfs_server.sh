echo "starting NFS server..."

sudo mkdir -p /mnt/data/nfs-storage
sudo chown nobody:nogroup /mnt/data/nfs-storage
sudo chmod 777 /mnt/data/nfs-storage

docker run -itd --privileged \
  --restart unless-stopped \
  -e SHARED_DIRECTORY=/data \
  -v /data/nfs-storage:/data \
  -p 2049:2049 \
  itsthenetwork/nfs-server-alpine:12
