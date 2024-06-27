
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list


sudo apt update

sudo apt-get install -y nvidia-container-toolkit

sudo nvidia-ctk runtime configure --runtime=docker

cat /etc/docker/daemon.json

sudo systemctl daemon-reload
sudo systemctl restart docker

#=== quick test
sudo docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi
#=== 
### Install Nvidia Docker runtime
#curl -s -L https://nvidia.github.io/nvidia-container-runtime/gpgkey | \
#  sudo apt-key add -
#distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
#curl -s -L https://nvidia.github.io/nvidia-container-runtime/$distribution/nvidia-container-runtime.list | \
#  sudo tee /etc/apt/sources.list.d/nvidia-container-runtime.list
#sudo apt-get update
#sudo apt-get install -y nvidia-container-runtime
#sudo systemctl restart docker

#sudo gpasswd -a $USER docker
#sudo usermod -a -G docker $(whoami)
#newgrp docker

