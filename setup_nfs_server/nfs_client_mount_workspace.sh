
echo "install NFS client library"
sudo apt install nfs-common -y

echo "create mount point /mnt/workspace/..."
sudo mkdir -p /mnt/workspace
sudo chown nobody:nogroup /mnt/workspace
sudo chmod -R 777 /mnt/workspace

sudo mount -t nfs4 nfs: /mnt/workspace

echo "list contents"
ls -all /mnt/workspace

echo "show mounts"
df -T
